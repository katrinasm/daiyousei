#![allow(dead_code)]
use std::io;
use std::io::prelude::*;
use std::fs::File;
use std::fs::OpenOptions;
use std::fmt;
use std::path::Path;

#[derive(Debug)]
pub enum MMap {
	Lorom, Hirom, Sa1rom([u8; 4]), Sfxrom, Norom
}

impl fmt::Display for MMap {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		match *self {
			MMap::Lorom        => write!(f, "lorom"),
			MMap::Hirom        => write!(f, "hirom"),
			MMap::Sfxrom       => write!(f, "sfxrom"),
			MMap::Norom        => write!(f, "sfxrom"),
			MMap::Sa1rom(bnks) => write!(f, "sa1rom ${:02x}, ${:02x}, ${:02x}, ${:02x}", 
				bnks[0], bnks[1], bnks[2], bnks[3])
		}
	}
}

#[derive(Debug)]
pub struct InvalidAddressErr {
	pub address:  usize,
	pub mapper: MMap,
	pub direction: AddressDir
}

#[derive(Debug)]
pub enum AddressDir { ToSnes, ToPc }

pub struct RomBuf {
	pub buf: Vec<u8>,
	pub size: usize,
	header: usize,
	mapper: MMap
}

impl RomBuf {
	pub fn new() -> RomBuf {
		RomBuf {
			buf: vec![0; 16 * 1024 * 1024],
			size: 16 * 1024 * 1024,
			header: 0,
			mapper: MMap::Norom,
		}
	}
	
	pub fn from_file(path: &Path) -> io::Result<RomBuf> {
		let mut f = try!(File::open(path));
		let mut rom = RomBuf {
			buf: vec![],
			size: 0,
			header: 0,
			mapper: MMap::Lorom,
		};
		
		rom.size = try!(io::Read::read_to_end(&mut f, &mut rom.buf));
		
		rom.header = rom.size % 1024;
		
		if rom.header != 0 {
			rom.buf = rom.buf.split_off(rom.header);
			rom.size -= rom.header;
		}
		
		rom.buf.resize(16 * 1024 * 1024, 0);
		
		return Ok(rom);
	}
	
	pub fn into_file(&self, path: &Path) -> Option<io::Error> {
		let mut f = match OpenOptions::new()
				.read(true)
				.write(true)
				.create(true) 
				.open(path) {
			Ok(f) => f,
			Err(e) => return Some(e)
		};
		
		if let Err(e) = f.seek(io::SeekFrom::Start(self.header as u64)) {
			Some(e)
		} else if let Err(e) = f.write_all(&self.buf[.. self.size]) {
			Some(e)
		} else {
			None
		}
	}
	
	pub fn map(&self, addr: usize) -> Result<usize, InvalidAddressErr> {
		match self.mapper {
			MMap::Lorom => Ok(((addr & 0x7f_0000) >> 1) | (addr & 0x7fff)),
			MMap::Hirom => Ok(addr & 0x3f_ffff),
			MMap::Norom => Ok(addr),
			_ => unimplemented!()
		}
	}
	
	pub fn unmap(&self, ofs: usize) -> Result<usize, InvalidAddressErr> {
		match self.mapper {
			MMap::Lorom => Ok(((ofs & 0x3f_8000) << 1) | (ofs & 0x7fff) | 0x80_8000),
			MMap::Hirom => Ok(ofs & 0x3f_ffff | 0xc0_0000),
			MMap::Norom => Ok(ofs),
			_ => unimplemented!()
		}
	}
	
	pub fn set_long(&mut self, addr: usize, value: u32) -> Result<(), InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		try!(self.map(addr + 2));
		self.buf[ofs] = (value & 0xff) as u8;
		self.buf[ofs+1] = (value >> 8 & 0xff) as u8;
		self.buf[ofs+2] = (value >> 16 & 0xff) as u8;
		Ok(())
	}
	
	pub fn set_word(&mut self, addr: usize, value: u16) -> Result<(), InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		try!(self.map(addr + 1));
		self.buf[ofs] = (value & 0xff) as u8;
		self.buf[ofs + 1] = (value >> 8 & 0xff) as u8;
		Ok(())
	}
	
	pub fn set_byte(&mut self, addr: usize, value: u8) -> Result<(), InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		Ok(self.buf[ofs] = value)
	}
	
	pub fn set_bytes(&mut self, addr: usize, values: &[u8]) -> Result<(), InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		let end = try!(self.map(addr + values.len()));
		
		Ok(self.buf[ofs .. end].clone_from_slice(values))
	}
	
	pub fn clear_bytes(&mut self, addr: usize, len: usize) -> Result<(), InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		for i in 0 .. len {
			self.buf[ofs + i] = 0;
		}
		Ok(())
	}
	
	pub fn get_long(&self, addr: usize) -> Result<usize, InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		try!(self.map(addr + 2));
		Ok(self.buf[ofs] as usize
		   | ((self.buf[ofs + 1] as usize) << 8)
		   | ((self.buf[ofs + 2] as usize) << 16))
	}
	
	pub fn get_word(&self, addr: usize) -> Result<usize, InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		try!(self.map(addr + 1));
		Ok(self.buf[ofs] as usize
		   | ((self.buf[ofs + 1] as usize) << 8))
	}
	
	pub fn get_byte(&self, addr: usize) -> Result<u8, InvalidAddressErr> {
		let ofs = try!(self.map(addr));
		Ok(self.buf[ofs])
	}
}

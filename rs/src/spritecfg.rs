#![allow(dead_code)]
extern crate asar;
use std::path::{PathBuf, Path};
use std::io::prelude::*;
use std::fs::{File, OpenOptions};
use nom::*;

use asar::rom::RomBuf;

use parse_aux::dys_prefix;
use genus::Genus;
use dys_tables::DysTables;

#[derive(Debug)]
pub struct CfgErr {
	explain: String,
}

#[derive(Debug)]
pub struct SpriteCfg {
	pub genus: Genus,
	pub id: u16,
	pub tweak_bytes: [u8; 6],
	pub prop_bytes: [u8; 2],
	pub clipping: [u8; 4],
	dys_option_bytes: [u8; 2],
	acts_like: u8,
	extra_bytes: u8,

	name: String,
	desc: String,
	name_set: Option<String>,
	desc_set: Option<String>,
	source_path: PathBuf,
}

#[derive(Debug, Copy, Clone)]
pub struct InsertPoint {
	pub main: usize,
	pub init: usize,
}

impl SpriteCfg {
	pub fn parse(path: &Path, gen: Genus, id: u16, buf: &str) -> Result<SpriteCfg, CfgErr> {
		if let IResult::Done(rest, vsn) = dys_prefix(buf) {
			if vsn != 1 {
				return Err(CfgErr { explain: String::from("You have a cfg from the future") });
			} else {
				parse_newstyle(path, gen, id, rest)
			}
		} else {
			parse_oldstyle(path, gen, id, buf)
		}
	}

	pub fn new() -> SpriteCfg {
		SpriteCfg {
			genus: Genus::Std,
			id: 0,
			tweak_bytes: [0, 0, 0, 0, 0, 0],
			prop_bytes: [0, 0],
			clipping: [0, 0, 0, 0],
			dys_option_bytes: [0, 0],
			acts_like: 0,
			extra_bytes: 0,
			name: "".to_string(),
			desc: "".to_string(),
			name_set: None,
			desc_set: None,
			source_path: PathBuf::from(""),
		}
	}

	pub fn needs_init(&self) -> bool {
		match self.genus {
			Genus::Std => true,
			_ => false,
		}
	}

	pub fn placeable(&self) -> bool {
		self.genus.placeable()
	}

	pub fn assemble(&self,
	                rom: &mut RomBuf,
	                prelude: &str,
	                source: &Path,
	                temp: &Path)
	                -> asar::AResult<InsertPoint> {
		let (mut main, mut init) = (0usize, 0usize);
		let warns;

		let mut tempasm = OpenOptions::new()
			.write(true)
			.truncate(true)
			.create(true)
			.open(temp)
			.unwrap();

		tempasm.write_all(prelude.as_bytes()).unwrap();
		let mut source_buf = Vec::<u8>::with_capacity(8 * 1024); // A wild guess.

		let mut srcf = match File::open(source) {
			Ok(f) => f,
			Err(e) => {
				return Err((vec![asar::AsmError::Interface(format!("error opening \"{}\": {}",
				                                                   source.to_string_lossy(),
				                                                   e))],
				            vec![]))
			}
		};

		srcf.read_to_end(&mut source_buf).unwrap();
		tempasm.write_all(&source_buf).unwrap();

		drop(tempasm);

		warns = match asar::patch(temp, rom) {
			Ok((_, ws)) => ws,
			Err(ews) => return Err(ews),
		};

		for print in asar::prints() {
			let mut chunks = print.split_whitespace();
			let fst = chunks.next();
			let snd = chunks.next();
			match fst {
				Some("MAIN") => {
					match snd {
						Some(ofs) => main = usize::from_str_radix(ofs, 16).unwrap(),
						_ => return Err((vec![], vec![])),
					}
				}
				Some("INIT") => {
					match snd {
						Some(ofs) => init = usize::from_str_radix(ofs, 16).unwrap(),
						_ => return Err((vec![], vec![])),
					}
				}
				None => (),
				_ => return Err((vec![], vec![])),
			}
		}

		if main == 0 || (init == 0 && self.needs_init()) {
			return Err((vec![], vec![]));
		}

		Ok((InsertPoint {
			    main: main,
			    init: init,
		    },
		    warns))
	}

	pub fn apply_cfg(&self, rom: &mut RomBuf, tables: &DysTables) {
		match self.genus {
			Genus::Std | Genus::Gen | Genus::Sht | Genus::R1s => {
				if self.id < 0x200 {
					let size_ofs = if self.id < 0x100 {
						self.id as usize
					} else {
						self.id as usize + 0x100
					};
					let size = self.extra_bytes + 3;
					rom.set_byte(tables.sprite_sizes + size_ofs, size).unwrap();
					rom.set_byte(tables.sprite_sizes + size_ofs + 0x100, size).unwrap();

					let optbase = tables.option_bytes + (self.id as usize * 0x10);
					rom.set_byte(optbase, self.genus.to_byte()).unwrap();
					rom.set_byte(optbase + 1, self.acts_like).unwrap();
					rom.set_bytes(optbase + 2, &self.tweak_bytes).unwrap();
					rom.set_bytes(optbase + 8, &self.dys_option_bytes).unwrap();
					rom.set_bytes(optbase + 14, &self.prop_bytes).unwrap();
					rom.set_bytes(optbase + 10, &self.clipping).unwrap();
				};
			}
			Genus::Cls => {}
			_ => unimplemented!(),
		};
	}

	pub fn apply_offsets(&self, rom: &mut RomBuf, tables: &DysTables, ip: InsertPoint) {
		let ofs = self.id as usize * 3;
		match self.genus {
			g if g.placeable() => {
				rom.set_long(tables.main_ptrs + ofs, ip.main as u32).unwrap();
				rom.set_long(tables.init_ptrs + ofs, ip.init as u32).unwrap();
			}
			Genus::Cls => rom.set_long(tables.cls_ptrs + ofs, ip.main as u32).unwrap(),
			_ => unimplemented!(),
		};
	}

	pub fn name(&self, ebit: bool) -> &String {
		if ebit && self.name_set.is_some() {
			self.name_set.as_ref().unwrap()
		} else {
			&self.name
		}
	}

	pub fn desc(&self, ebit: bool) -> &String {
		if ebit && self.desc_set.is_some() {
			self.desc_set.as_ref().unwrap()
		} else {
			&self.desc
		}
	}

	pub fn uses_ebit(&self) -> bool {
		self.name_set.is_some()
	}

	pub fn place_mw2(&self, target: &mut Vec<u8>, ebit: bool) {
		if !self.placeable() {
			panic!("Attempted to place unplaceable sprite")
		};
		let b0 = 0x89;
		let b1 = 0x80;
		let num_extra_bit: u8 = if self.id & 0x100 == 0 { 0 } else { 8 };
		let ebit_val: u8 = if !ebit { 0 } else { 4 };

		let b0 = b0 | num_extra_bit | ebit_val;

		target.push(b0);
		target.push(b1);

		if self.id >= 0x200 {
			target.push(0xf8 + self.extra_bytes);
		}
		target.push((self.id & 0xff) as u8);

		for _ in 0..self.extra_bytes {
			target.push(0);
		}
	}

	pub fn dys_option_bytes(&self) -> &[u8] {
		&self.dys_option_bytes
	}
	pub fn source_path(&self) -> &PathBuf {
		&self.source_path
	}
}

fn default_name(path: &Path, gen: Genus, id: u16) -> (String, String) {
	let root = match path.file_stem() {
		Some(s) => s.to_string_lossy().into_owned(),
		None => format!("Custom {} #{:03x}", gen.shortname(), id),
	};
	(root.clone(), root + " (extra bit set)")
}

fn parse_newstyle(path: &Path, gen: Genus, id: u16, buf: &str) -> Result<SpriteCfg, CfgErr> {
	let (mut got_name, mut got_desc): (Option<String>, Option<String>) = (None, None);

	let mut cfg = SpriteCfg {
		genus: gen,
		id: id,
		..SpriteCfg::new()
	};
	let mut buf = buf;
	while let IResult::Done(rest, (name, value)) = cfg_line(buf) {
		buf = rest;
		match name {
			"acts-like" => cfg.acts_like = try!(read_byte(value)),
			"source" => cfg.source_path = path.with_file_name(value),
			"props" => try!(read_bytes(value, &mut cfg.tweak_bytes)),
			"xbytes" => cfg.extra_bytes = try!(read_byte(value)),
			"ext-props" => try!(read_bytes(value, &mut cfg.prop_bytes)),
			"dys-opts" => try!(read_bytes(value, &mut cfg.dys_option_bytes)),
			"ext-clip" => try!(read_bytes(value, &mut cfg.clipping)),
			"name" => got_name = Some(String::from(value)),
			"description" => got_desc = Some(String::from(value)),
			"desc-set" => cfg.desc_set = Some(String::from(value)),
			"name-set" => cfg.name_set = Some(String::from(value)),
			"ext-prop-def" | "m16d" | "tilemap" => (),
			_ => return Err(CfgErr { explain: format!("bad field name: \"{}\"", name) }),
		};
	}

	if let Some(s) = got_name {
		cfg.name = s;
	} else {
		let t = default_name(path, gen, id);
		cfg.name = t.0;
		cfg.name_set = Some(t.1);
	};

	if let Some(s) = got_desc {
		cfg.desc = s;
	} else {
		cfg.desc = cfg.name.clone();
		cfg.desc_set = cfg.name_set.clone();
	};

	if cfg.source_path.file_name() == None {
		Err(CfgErr { explain: String::from("Sprite needs a source file") })
	} else {
		Ok(cfg)
	}
}

fn parse_oldstyle(path: &Path, gen: Genus, id: u16, buf: &str) -> Result<SpriteCfg, CfgErr> {
	let mut it = buf.split_whitespace().skip(1);
	let mut d = [0u8; 9];
	for output_byte in &mut d {
		if let Some(s) = it.next() {
			*output_byte = try!(read_byte(s));
		} else {
			return Err(CfgErr { explain: String::from("Old-style CFG too short") });
		}
	}

	let (name, name_set) = default_name(path, gen, id);
	let (desc, desc_set) = (name.clone(), name_set.clone());

	if let Some(s) = it.next() {
		Ok(SpriteCfg {
			genus: gen,
			id: id,
			acts_like: d[0],
			tweak_bytes: [d[1], d[2], d[3], d[4], d[5], d[6]],
			prop_bytes: [d[7], d[8]],
			source_path: path.with_file_name(s),
			name: name,
			name_set: Some(name_set),
			desc: desc,
			desc_set: Some(desc_set),
			..SpriteCfg::new()
		})
	} else {
		Err(CfgErr { explain: String::from("Old-style CFG too short") })
	}
}

fn read_byte(s: &str) -> Result<u8, CfgErr> {
	let iter = s.trim().chars();
	let mut n = 0u32;
	let mut read = false;

	for ch in iter {
		if let Some(v) = ch.to_digit(0x10) {
			n *= 0x10;
			n += v;
			read = true;
		} else {
			return Err(CfgErr { explain: String::from("Non-byte data in byte field") });
		}
	}

	if !read {
		Err(CfgErr { explain: String::from("Expected a byte, found nothing") })
	} else {
		Ok(n as u8)
	}
}

fn read_bytes(s: &str, buf: &mut [u8]) -> Result<(), CfgErr> {
	let mut bytes = Vec::<u8>::with_capacity(buf.len());
	for b in s.split_whitespace() {
		bytes.push(try!(read_byte(b)));
	}

	if bytes.len() != buf.len() {
		Err(CfgErr {
			explain: format!("Wrong length byte sequence: expected {} bytes, got {}",
			                 buf.len(),
			                 bytes.len()),
		})
	} else {
		for (i, b) in bytes.iter().enumerate() {
			buf[i] = *b;
		}
		Ok(())
	}
}

fn tag_ending_s(ch: char) -> bool {
	ch == ' ' || ch == ':'
}
fn line_ending_s(ch: char) -> bool {
	ch == '\r' || ch == '\n'
}

named!(cfg_line(&str) -> (&str, &str),
  chain!(
          multispace?                   ~
    name: take_till_s!(tag_ending_s)    ~
	      space?                        ~
          tag_s!(":")                   ~
	      space?                        ~
	valu: take_till_s!(line_ending_s)   ~
	      multispace?                   ,
	|| (name, valu)
  )
);

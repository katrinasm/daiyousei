// extern crate libc;
#[macro_use]
extern crate nom;
extern crate asar;
extern crate rand;
use std::collections::{HashSet, HashMap};
use std::env;
use std::io::prelude::*;
use std::fs::{read_dir, File, OpenOptions};
use std::path::{Path, PathBuf};
use rand::random;

mod genus;
mod parse_aux;
mod spritecfg;
mod insertlist;
mod dys_tables;
mod desclist;

use asar::rom::RomBuf;
use spritecfg::{SpriteCfg, InsertPoint};
use dys_tables::DysTables;

macro_rules! error_exit {
	($x: expr) => {{ println!("{}",$x); return; }}
}

macro_rules! require_ok {
	($x: expr) => {{
		match $x {
			Ok(ok) => ok,
			Err(err) => error_exit!(err),
		}
	}}
}

struct CmdArgs {
	flags: HashSet<char>,
	romname: String,
	listname: String,
}

fn main() {
	let args = require_ok!(parse_args(env::args()));

	let verbose = args.flags.contains(&'v');
	let gen_ssc = args.flags.contains(&'d');
	let gen_collection = args.flags.contains(&'c');

	for flag in args.flags {
		println!("ran with -{}", flag);
	}

	if !asar::init() {
		error_exit!("No asar, why, what");
	};

	let base_dir = PathBuf::new();

	let rom_path = base_dir.join(&args.romname);
	let list_path = base_dir.join(&args.listname);

	let mut rom = match RomBuf::from_file(&rom_path) {
		Ok(rom) => rom,
		Err(e) => {
			println!("Couldn't open ROM ({}): {}", rom_path.display(), e);
			return;
		}
	};

	let mut insert_list = match File::open(&list_path) {
		Ok(il) => il,
		Err(e) => {
			println!("Couldn't open insert list ({}): {}", list_path.display(), e);
			return;
		}
	};

	let mut list_buf = String::new();
	require_ok!(insert_list.read_to_string(&mut list_buf));
	let list_buf = list_buf;

	let space_freed = free_tool_space(&mut rom);

	println!("Freed {} kilobytes of space from previous runs.",
	         space_freed / 1024);

	let patch_dir = base_dir.join("patch");

	if let Err((es, ws)) = patch_subroutines(&mut rom, &patch_dir, &base_dir) {
		for e in es {
			println!("SUB: {}", e);
		}
		for w in ws {
			println!("SUB: {}", w);
		}
		return;
	};
	println!("Inserted subroutines");

	let patch_path = patch_dir.join("daiyousei.asm");
	match asar::patch(&patch_path, &mut rom) {
		Ok((_, warns)) => {
			for warn in warns {
				println!("Warning: {}", warn)
			}
		}
		Err((errors, warns)) => {
			for error in errors {
				println!("{}", error)
			}
			for warn in warns {
				println!("{}", warn)
			}
			return;
		}
	};

	for line in asar::prints().into_iter() {
		println!("Main patch: {}", line);
	}

	let dys_data = get_tables().unwrap();
	copy_sprite_settings(&mut rom, dys_data.option_bytes);

	let groups = require_ok!(insertlist::parse_list(&list_buf));

	let cfgs = require_ok!(get_cfgs(groups, &base_dir));

	match insert_sprites(&mut rom, &cfgs, &patch_dir, &dys_data, verbose) {
		Err((errs, warns)) => {
			println!("==== Insertion was stopped by an error ====");
			for err in errs {
				println!("Error: {}", err);
			}
			for warn in warns {
				println!("Warning: {}", warn);
			}
			return;
		}
		_ => (),
	};

	print!("Writing rom ... ");
	rom.into_file(&rom_path);
	println!("written!");

	if gen_ssc {
		print!("Creating sprite descriptions ... ");
		let ssc_path = rom_path.with_extension("ssc");
		let mut ssc_file = OpenOptions::new().write(true).create(true).open(ssc_path).unwrap();
		desclist::write_desclist(&mut ssc_file, &cfgs);
		println!("done!");
	};

	if gen_collection {
		print!("Creating sprite list ... ");
		let mw2_path = rom_path.with_extension("mw2");
		let mut mw2_file = OpenOptions::new().write(true).create(true).open(mw2_path).unwrap();

		let mwt_path = rom_path.with_extension("mwt");
		let mut mwt_file = OpenOptions::new().write(true).create(true).open(mwt_path).unwrap();

		desclist::write_collection(&mut mwt_file, &mut mw2_file, &cfgs);
		println!("done!");
	};
}

fn parse_args(argv: env::Args) -> Result<CmdArgs, String> {
	let mut val = CmdArgs {
		flags: HashSet::<char>::new(),
		romname: String::new(),
		listname: String::new(),
	};

	for s in argv.skip(1) {
		if s.starts_with("-") {
			for c in s.chars().skip(1) {
				val.flags.insert(c);
			}
		} else {
			if val.romname.is_empty() {
				val.romname = s;
			} else if val.listname.is_empty() {
				val.listname = s;
			} else {
				return Err("Too many names!".to_string());
			}
		}
	}

	if val.romname.is_empty() || val.listname.is_empty() {
		Err("Need a rom and sprite list name!".to_string())
	} else {
		Ok(val)
	}
}

fn get_cfgs(insert_list: insertlist::InsertList,
            base_dir: &PathBuf)
            -> Result<Vec<SpriteCfg>, String> {
	let mut cfgs = Vec::<SpriteCfg>::new();

	for (gen, sprites) in insert_list.iter() {
		for &(id, ref cfg_path) in sprites {
			let mut full_path = base_dir.clone();
			full_path.push(gen.dir());
			full_path.push(cfg_path);
			let mut cfg_buf = String::new();

			let mut f = match File::open(&full_path) {
				Ok(f) => f,
				Err(e) => return Err(format!("Error reading {}: {}", full_path.display(), e)),
			};

			match f.read_to_string(&mut cfg_buf) {
				Ok(_) => (),
				Err(e) => return Err(format!("Error reading {}: {}", full_path.display(), e)),
			};

			match SpriteCfg::parse(&full_path, *gen, id as u16, &cfg_buf) {
				Ok(cfg) => cfgs.push(cfg),
				Err(e) => return Err(format!("{}: {:?}", full_path.display(), e)),
			}
		}
	}

	Ok(cfgs)
}

fn patch_subroutines(rom: &mut RomBuf, patch_dir: &Path, base_dir: &Path) -> asar::AResult<()> {
	let patch_path = patch_dir.join("subroutines.asm");
	let usr_dir_path = base_dir.join("library");
	let ptrf_path = patch_dir.join("prelude").join("subroutine_ptrs.asm");
	let usrf_path = patch_dir.join("temp_subroutines.asm");

	let prelude = "incsrc \"subroutine_prelude.asm\"\r\n";

	try!(asar::patch(&patch_path, rom));

	let mut ptrf = match OpenOptions::new()
		.write(true)
		.truncate(true)
		.create(true)
		.open(ptrf_path) {
		Ok(o) => o,
		Err(_) => return Err((vec![], vec![])),
	};

	for print in asar::prints() {
		ptrf.write_all(print.as_bytes()).unwrap();
		ptrf.write_all(b"\r\n").unwrap();
	}
	ptrf.sync_all().unwrap();

	let mut usrf = match OpenOptions::new()
		.write(true)
		.truncate(true)
		.create(true)
		.open(&usrf_path) {
		Ok(o) => o,
		Err(_) => return Err((vec![], vec![])),
	};
	let mut namespace_id = random::<u32>();
	usrf.write_all(prelude.as_bytes()).unwrap();

	let dir = read_dir(usr_dir_path);

	if dir.is_ok() {
		for entry in dir.unwrap() {
			let p = entry.unwrap().path();
			if p.extension() == Some(&std::ffi::OsString::from("asm")) {
				println!("Subroutines in [{}] [DYS_AUTOSPACE_{:08X}]",
				         p.to_string_lossy(),
				         namespace_id);
				let mut f = File::open(p).unwrap();
				let mut usr_buf = Vec::new();
				f.read_to_end(&mut usr_buf).unwrap();
				usrf.write_all(format!("\r\nnamespace DYS_AUTOSPACE_{:08X}\r\n", namespace_id)
						.as_bytes())
					.unwrap();
				usrf.write_all(&usr_buf).unwrap();
				namespace_id += 1;
			};
		}

		try!(asar::patch(&usrf_path, rom));

		for print in asar::prints() {
			ptrf.write_all(print.as_bytes()).unwrap();
			ptrf.write_all(b"\r\n").unwrap();
		}

		ptrf.sync_all().unwrap();
	};

	Ok(((), vec![]))
}

fn insert_sprites(rom: &mut RomBuf,
                  cfgs: &Vec<SpriteCfg>,
                  patch_dir: &Path,
                  dys_data: &DysTables,
                  verbose: bool)
                  -> asar::AResult<()> {
	let mut routines = HashMap::<PathBuf, InsertPoint>::new();
	let prelude = "incsrc \"sprite_prelude.asm\"\r\n";
	let temploc = patch_dir.join("temp_sprite.asm");

	for ref cfg in cfgs {
		let src = &cfg.source_path().to_owned();
		let (ip, warns) = if routines.contains_key(src) {
			let ip = *routines.get(src).unwrap();
			println!("Inserting {} #{:03x} [{}] (repeat)",
			         cfg.genus.shortname(),
			         cfg.id,
			         src.to_string_lossy());
			cfg.apply_cfg(rom, dys_data);
			cfg.apply_offsets(rom, dys_data, ip);
			(ip, vec![])
		} else {
			println!("Inserting {} #{:03x} [{}]",
			         cfg.genus.shortname(),
			         cfg.id,
			         src.to_string_lossy());
			let (ip, warns) = try!(cfg.assemble(rom, prelude, src, &temploc));
			cfg.apply_cfg(rom, dys_data);
			cfg.apply_offsets(rom, dys_data, ip);
			routines.insert(src.clone(), ip);
			(ip, warns)
		};

		if verbose {
			print!("\tMAIN: ${:06x}\n\tINIT: ${:06x}\n", ip.main, ip.init);
			for warn in warns {
				println!("\tWarning: {}", warn);
			}
		};
	}

	Ok(((), vec![]))
}

fn get_tables() -> Result<DysTables, String> {
	Ok(DysTables {
		sprite_sizes: try!(possible_label("DYS_DATA_SPRITE_SIZES")),
		storage_ptrs: try!(possible_label("DYS_DATA_STORAGE_PTRS")),
		option_bytes: try!(possible_label("DYS_DATA_OPTION_BYTES")),
		init_ptrs: try!(possible_label("DYS_DATA_INIT_PTRS")),
		main_ptrs: try!(possible_label("DYS_DATA_MAIN_PTRS")),
		cls_ptrs: try!(possible_label("DYS_DATA_CLS_PTRS")),
		xsp_ptrs: try!(possible_label("DYS_DATA_XSP_PTRS")),
		mxs_ptrs: try!(possible_label("DYS_DATA_MXS_PTRS")),
	})
}

fn possible_label(name: &str) -> Result<usize, String> {
	match asar::label(name) {
		Some(v) => Ok(v),
		None => Err(format!("Missing label: {}", name)),
	}
}

fn free_tool_space(rom: &mut RomBuf) -> usize {
	let mut i = 0usize;
	let mut reverted_mdk = false;
	let mut cleared_bytes = 0;

	while i < rom.buf.len() - 11 {
		if eq_str_bytes("STAR", &rom.buf[i..]) {
			// the length restriction on this loop
			// lets us know these won’t fail.
			let len = rom.get_word(rom.unmap(i + 4).unwrap()).unwrap();
			let nlen = rom.get_word(rom.unmap(i + 6).unwrap()).unwrap();
			if len == nlen ^ 0xffff {
				let len = if len == 0 { 0x1_0000 } else { len + 1 };

				if !reverted_mdk && eq_str_bytes("MDK", &rom.buf[i + 8..]) {
					revert_mdk(rom);
					reverted_mdk = true;
				}

				if len > 3 && eq_str_bytes("DYS", &rom.buf[i + 8..]) ||
				   eq_str_bytes("MDK", &rom.buf[i + 8..]) {
					let addr = rom.unmap(i).unwrap();
					rom.clear_bytes(addr, len + 8).unwrap();
					cleared_bytes += len + 8;
				}

				i += len + 8;

			} else {
				i += 1;
			}
		} else {
			i += 1;
		}
	}

	cleared_bytes
}

fn revert_mdk(rom: &mut RomBuf) {
	rom.set_bytes(0x008127, &[0xbd, 0xc8, 0x14, 0xf0]).unwrap();
	rom.set_bytes(0x008151, &[0xa9, 0xff, 0x9d, 0x1a, 0x16]).unwrap();
	rom.set_bytes(0x008172, &[0xa9, 0x08, 0x9d, 0xc8, 0x14]).unwrap();
	rom.set_bytes(0x0082b3, &[0xa7, 0x87]).unwrap();
	rom.set_bytes(0x0085c3, &[0x9c, 0x91, 0x14, 0xb5, 0x9e]).unwrap();
	rom.set_bytes(0x0087a7, &[0x22, 0x59, 0xda, 0x2]).unwrap();
	rom.set_bytes(0x00c089,
		           &[0xbd, 0xd4, 0x14, 0x9d, 0x7b, 0x18, 0x29, 0x01, 0x9d, 0xd4, 0x14])
		.unwrap();
	rom.set_bytes(0x00c4cb, &[0xc9, 0x21, 0xd0, 0x69]).unwrap();
	rom.set_bytes(0x00c6d6, &[0xaa, 0xbd, 0x09, 0xc6]).unwrap();
	rom.set_bytes(0x00d43e, &[0x9e, 0xc8, 0x14, 0x60]).unwrap();
	rom.set_bytes(0x01a866, &[0xc9, 0xe7, 0x90, 0x22]).unwrap();
	rom.set_bytes(0x01a94b, &[0x29, 0x0d, 0x9d, 0xe0, 0x14]).unwrap();
	rom.set_bytes(0x01a963, &[0x29, 0x0d, 0x9d, 0xd4, 0x14]).unwrap();
	rom.set_bytes(0x01a9a6, &[0xaa, 0xbf, 0x59, 0xf6, 0x07]).unwrap();
	rom.set_bytes(0x01a9c9, &[0x22, 0xd2, 0xf7, 0x07]).unwrap();
	rom.set_bytes(0x01aba0, &[0xa5, 0x04, 0x38, 0xe9, 0xc8]).unwrap();
	rom.set_bytes(0x01affe, &[0xad, 0xb9, 0x18, 0xf0, 0x27]).unwrap();
	rom.set_bytes(0x01b395, &[0xbc, 0xab, 0x17, 0xf0, 0x0a]).unwrap();
	rom.set_bytes(0x07f785, &[0xa9, 0x01, 0x9d, 0xa0, 0x15]).unwrap();
}

fn eq_str_bytes(s: &str, bytes: &[u8]) -> bool {
	s.bytes().zip(bytes).all(|(c, b)| c == *b)
}

fn copy_sprite_settings(rom: &mut RomBuf, table: usize) {
	let orig_table: usize = 0x07f26c;

	rom.clear_bytes(table, 0xc8 * 16).unwrap();

	for i in 0..0xc8 {
		rom.set_byte(table + i * 16 + 1, i as u8).unwrap();
		// This looks ridiculous because it is.
		for j in 0..6 {
			let b = rom.get_byte(orig_table + i + 0xc9 * j).unwrap();
			rom.set_byte(table + i * 16 + 2 + j, b).unwrap();
		}
	}
	// + 1 is to make it inclusive.
	// shooters
	for i in 0x0c9..0x0ca + 1 {
		rom.set_byte(table + i * 16, 3).unwrap();
	}
	// generators
	for i in 0x0cb..0x0d9 + 1 {
		rom.set_byte(table + i * 16, 2).unwrap();
	}
	// r1s
	for i in 0x0da..0x0e0 + 1 {
		rom.set_byte(table + i * 16, 4).unwrap();
	}
	// cluster r1s
	for i in 0x0e1..0x0e6 + 1 {
		rom.set_byte(table + i * 16, 4).unwrap();
	}
	// scroll clear
	for i in 0x0e7..0x0f5 + 1 {
		rom.set_byte(table + i * 16, 5).unwrap();
	}
	// scroll set
	for i in 0x1e7..0x1f5 + 1 {
		rom.set_byte(table + i * 16, 5).unwrap();
	}
}

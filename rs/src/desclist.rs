use std::fs::File;

use std::io::prelude::*;

use spritecfg;

pub fn write_desclist(f: &mut File, cfgs: &Vec<spritecfg::SpriteCfg>) {
	for cfg in cfgs {
		if cfg.id >= 0x200 {
			continue;
		};
		
		let byte0 = (cfg.id & 0xff) as u8;
		let byte1 = if cfg.id < 0x100 { 0 } else { 0x20 };
		let m16byte: u8 = byte1 | 0x02;
		
		writeln!(f, "{:02x}\t{:02x}\t{}",
			byte0,
			byte1,
			cfg.desc(false),
		).unwrap();
		
		writeln!(f, "{:02x}\t{:02x}\t{}",
			byte0,
			m16byte,
			"0,0,0000 4,4,010a"
		).unwrap();
		
		let byte1_s = byte1 | 0x10;
		let m16byte_s = m16byte | 0x10;
		writeln!(f, "{:02x}\t{:02x}\t{}",
			byte0,
			byte1_s,
			cfg.desc(true),
		).unwrap();
		
		writeln!(f, "{:02x}\t{:02x}\t{}",
			byte0,
			m16byte_s,
			"0,0,0000 3,4,010c, 6,4,010a"
		).unwrap();
	};
}

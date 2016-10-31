use nom::*;
use parse_aux::{dys_prefix};
use std::collections::HashMap;
use std::path::{Path,PathBuf};
use genus::*;

pub type InsertList = HashMap<Genus, Vec<(u32, PathBuf)>>;

pub fn parse_list(list: &str) -> Result<InsertList, String> {
	if let IResult::Done(rest, vsn) = dys_prefix(list) {
		if vsn != 1 {
			Err(String::from("You have a sprite list from the future"))
		} else {
			parse_newstyle(rest)
		}
	} else {
		parse_oldstyle(list)
		//Err(String::from("That isn't real"))
	}
}

fn parse_newstyle(list: &str) -> Result<HashMap<Genus, Vec<(u32, PathBuf)>>, String> {
	let mut genus = Genus::Std;
	let mut hm = HashMap::new();

	for line in list.lines().map(str::trim) {
		let mut here = line.chars();
		let first = match here.next() {
			Some(ch) => ch,
			None => continue,
		};

		if first == '@' {
			genus = try!(Genus::from_str(here.as_str()));
		} else if first == '#' {
			let (num, path) = try!(sprite_line(here.as_str()));
			if num >= 0x400 {
				return Err(format!("sprite number too high: #{:03x}", num));
			}

			let v = hm.entry(genus).or_insert_with(Vec::new);
			v.push((num, path));
		} else {
			return Err(format!("cannot start a command with '{}'", first));
		};
	};

	Ok(hm)
}

fn sprite_line(line: &str) -> Result<(u32, PathBuf), String> {
	let mut parts = line.splitn(2, char::is_whitespace);
	let (num_s, path_s) = match (parts.next(), parts.next()) {
		(Some(s0), Some(s1)) => (s0,s1),
		_ => return Err(String::from("# needs a sprite number and path")),
	};

	let num = try!(sprite_num(num_s));
	let path = Path::new(path_s.trim_left()).to_path_buf();

	Ok((num, path))
}

fn parse_oldstyle(list: &str) -> Result<HashMap<Genus, Vec<(u32, PathBuf)>>, String> {
	let mut hm = HashMap::new();

	let mut it = list.split_whitespace();

	while let Some(num_s) = it.next() {
		if let Some(path_s) = it.next() {
			let num = try!(sprite_num(num_s));

			let genus;
			if num < 0xc0 {
				genus = Genus::Std;
			} else if num < 0xd0 {
				genus = Genus::Sht;
			} else if num < 0xe0 {
				genus = Genus::Gen;
			} else {
				return Err(String::from("Invalid sprite number for old-style CFG"));;
			}

			let num = num + 0x100;
			let path = PathBuf::from(path_s);

			let prevs = hm.entry(genus).or_insert_with(Vec::new);
			prevs.push((num, path));
		} else {
			return Err(String::from("sprite number needs path"));
		}
	}

	Ok(hm)
}

fn sprite_num(s: &str) -> Result<u32, String> {
	match u32::from_str_radix(s, 16) {
		Ok(n) => Ok(n),
		Err(_) => Err(format!("\"{}\" is not a valid sprite number", s)),
	}
}

#[cfg(test)]
mod test {
	use std::collections::HashMap;
	use std::path::PathBuf;

	use genus::Genus;
	use super::parse_oldstyle;

	#[test]
	fn simple_old_style() {
		let input = "00 donut_lift.cfg\n01 blooper.cfg\n";
		let mut expected = HashMap::new();
		expected.insert(Genus::Std,
		                vec![(0x100, PathBuf::from("donut_lift.cfg")),
		                     (0x101, PathBuf::from("blooper.cfg"))]);
		assert_eq!(parse_oldstyle(input), Ok(expected));
	}
}

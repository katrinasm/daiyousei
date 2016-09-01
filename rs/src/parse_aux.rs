use nom::*;

pub fn positive_dec(inp: &str) -> IResult<&str, u32> {
	positive_w_radix(inp, 10)
}

fn positive_w_radix(inp: &str, radix: u32) -> IResult<&str, u32> {
	let mut here = inp.chars();
	let mut acc = 0u32;
	let mut read = false;
	while let Some(ch) = here.next() {
		if let Some(v) = ch.to_digit(radix) {
			acc *= radix;
			acc += v;
			read = true;
		} else {
			if read {
				return IResult::Done(here.as_str(), acc);
			} else {
				break;
			}
		}
	}
	panic!("NO NUMBER");
}

pub fn dys_prefix(inp: &str) -> IResult<&str, u32> {
	get_dys_v(inp)
}

named!(get_dys_v(&str) -> u32,
  chain!(
             space?              ~
             tag_s!("DYS")       ~
             space?              ~
    version: positive_dec        ~
             multispace?         ,
    || version
  )
);

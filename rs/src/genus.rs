#[derive(Debug, Hash, PartialEq, Eq, Clone, Copy)]
pub enum Genus {
	Std,
	Gen,
	Sht,
	R1s,
	Cls,
	Scl,
}

impl Genus {
	pub fn shortname(self) -> &'static str {
		match self {
			Genus::Std => "std",
			Genus::Gen => "gen",
			Genus::Sht => "sht",
			Genus::R1s => "r1s",
			Genus::Cls => "cls",
			Genus::Scl => "scl",
		}
	}

	pub fn dir(self) -> &'static str {
		match self {
			Genus::Std => "sprites",
			Genus::Gen => "generators",
			Genus::Sht => "shooters",
			Genus::R1s => "runonces",
			Genus::Cls => "clusters",
			Genus::Scl => "scrollers",
		}
	}

	pub fn to_byte(self) -> u8 {
		match self {
			Genus::Std => 1,
			Genus::Gen => 2,
			Genus::Sht => 3,
			Genus::R1s => 4,
			Genus::Cls => 5,
			Genus::Scl => 6,
		}
	}

	pub fn from_str(name: &str) -> Result<Genus, String> {
		match name {
			"standard" => Ok(Genus::Std),
			"shooter" => Ok(Genus::Sht),
			"generator" => Ok(Genus::Gen),
			"run-once" => Ok(Genus::R1s),
			"cluster" => Ok(Genus::Cls),
			"scroll" => Ok(Genus::Scl),
			_ => Err(String::from("Bad sprite type")),
		}
	}

	pub fn placeable(self) -> bool {
		match self {
			Genus::Std | Genus::Gen | Genus::Sht | Genus::R1s | Genus::Scl => true,
			_ => false,
		}
	}
}

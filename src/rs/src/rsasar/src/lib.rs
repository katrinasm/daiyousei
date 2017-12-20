#![allow(dead_code)]
extern crate libc;
pub mod rom;

use rom::RomBuf;
use std::ptr;
use std::ffi::CStr;
use std::ffi::CString;
use std::fmt;
use std::error::Error;
use std::collections::HashMap;
use std::path::Path;
use libc::{c_int, c_char, c_double};

#[allow(non_camel_case_types)]
type c_bool = c_char;

const EXPECTED_API_VER: i32 = 200;

#[derive(Debug)]

/// Provides a storage structure for Asar’s errors.
///
/// Asar’s API provides very poor guarantees about the lifetimes of its errors.
/// This module copies them, also hiding the quite messy fields of Asar’s error type.
/// In the future, some of these fields may be made public or given accessors,
/// but for now they are mainly intended to be printed and shown to users.

pub enum AsmError {
	Patch(PatchError),
	Interface(String),
}

#[derive(Debug)]
pub struct PatchError {
	fulldata: String,
	rawdata: String,
	block: Option<String>,
	line: i32,
	filename: String,
	caller_filename: Option<String>,
	caller_line: Option<i32>,
}

impl fmt::Display for AsmError {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		match self {
			&AsmError::Patch(ref pe)     => write!(f, "{}", pe.fulldata),
			&AsmError::Interface(ref ie) => write!(f, "{}", ie),
		}
	}
}

impl Error for AsmError {
	fn description(&self) -> &str {
		"Asar assembly error"
	}
	// Asar never provides us anything like a 'cause', only text & line numbers.
}

/// Represents a label from Asar, which maps a name to a SNES address.
#[derive(Debug)]
pub struct Label {
	name: String,
	location: usize,
}

/// Represents a define from Asar, which maps a name to a string.
///
/// Asar defines are like C preprocessor defines (without arguments) if the C
/// preprocessor worked on bytes instead of tokens. A define name is
/// essentially `[a-zA-Z0-9_]+` - note that it is allowed to have a define
/// name which starts with, or is entirely, numerals, such as "1969".
///
/// A define maps its name to a sequence of (non-null?) bytes.
/// These bytes are usually but not always valid to place elsewhere in a source
/// file - they are not parsed until after the define is expanded,
/// so they may contain purely erroneous sequences.
///
/// In assembly source files, defines are prefixed with b'!', but this is not
/// part of the name.
#[derive(Debug)]
pub struct Define {
pub name: String,
pub contents: String,
}

pub type AResult<T> = Result<(T, Vec<AsmError>), (Vec<AsmError>, Vec<AsmError>)>;

#[repr(C)]
struct raw_errordata {
	fullerrdata: *const c_char,
	rawerrdata: *const c_char,
	block: *const c_char,
	filename: *const c_char,
	line: c_int,
	callerfilename: *const c_char,
	callerline: c_int,
}

#[repr(C)]
struct raw_labeldata {
	name: *const c_char,
	location: c_int,
}

#[repr(C)]
struct raw_definedata {
	name: *const c_char,
	contents: *const c_char,
}

#[link(name = "asar", kind = "dylib")]
extern {
	fn asar_version() -> c_int;
	fn asar_apiversion() -> c_int;
	fn asar_init() -> c_bool;
	fn asar_reset() -> c_bool;
	fn asar_patch(patchloc: *const c_char, romdata: *mut c_char,
	              buflen: c_int, romlen: *mut c_int)
	           -> c_bool;
	fn asar_maxromsize() -> c_int;
	fn asar_close() -> ();
	fn asar_geterrors(count: *mut c_int) -> *const raw_errordata;
	fn asar_getwarnings(count: *mut c_int) -> *const raw_errordata;
	fn asar_getprints(count: *mut c_int) -> *const *const c_char;
	fn asar_getalllabels(count: *mut c_int) -> *const raw_labeldata;
	fn asar_getalldefines(count: *mut c_int) -> *const raw_definedata;
	fn asar_getlabelval(name: *const c_char) -> c_int;
	fn asar_getdefine(name: *const c_char) -> *const c_char;
	fn asar_resolvedefines(data: *const c_char) -> *const c_char;
	fn asar_math(math: *const c_char, error: *mut *const c_char) -> c_double;
}

unsafe fn asar_array_info<T>(getarray: unsafe extern "C" fn(*mut c_int) -> *const T)
-> (*const T, usize) {
	let mut cnt: c_int = 0;
	let ptr = getarray(&mut cnt);
	if ptr.is_null() {
		panic!("Asar returned null array");
	}
	(ptr, cnt as usize)
}

fn asar_array_convert<T, U, F>(
		getarray: unsafe extern "C" fn(*mut c_int) -> *const T,
		convert: F)
		-> Vec<U>
		where F: Fn(&T) -> U
		{
	let (ptr, len) = unsafe { asar_array_info(getarray) };

	let mut v = Vec::with_capacity(len);

	for i in 0 .. len {
		let r = unsafe { &*ptr.offset(i as isize) };
		v.push(convert(r));
	};

	v
}

fn asar_map_convert<T: Sized, K, V, FK, FV>(
		getarray: unsafe extern "C" fn(*mut c_int) -> *const T,
		kconvert: FK,
		vconvert: FV)
		-> HashMap<K, V>
		where K: std::hash::Hash + Eq,
		      FK: Fn(&T) -> K,
		      FV: Fn(&T) -> V,
		{
	let (ptr, len) = unsafe { asar_array_info(getarray) };

	let mut hm = HashMap::with_capacity(len);

	for i in 0 .. len {
		let r = unsafe { &*ptr.offset(i as isize) };
		hm.insert(kconvert(r), vconvert(r));
	};

	hm
}

/// Provides Asar’s version in its characteristic format.
///
/// Asar’s version format is described by a comment in a header file as
/// "the version, in the format major*10000+minor*100+bugfix*1.
/// This means that 1.2.34 would be returned as 10234."
///
/// It is not clear if Asar is planned to follow any particular versioning scheme.
/// If you need a feature and know what version it first appears in,
/// check if this is less than that.
pub fn version() -> i32 {
	unsafe {
		asar_version() as i32
	}
}

/// Provides Asar’s API version in its characteristic version format.
///
/// Note that this is the version of the API specifically and does not guarantee
/// any assembler features. If you need to check for a feature’s presence, you
/// should check version().
///
/// Asar’s version format is described by a comment in a header file as
/// "the version, in the format major*10000+minor*100+bugfix*1.
/// This means that 1.2.34 would be returned as 10234."
///
/// Note that although this function is provided, this module already checks
/// Asar’s API version. Just about the only case you would need to call this
/// is to check for a bugfix released and not yet checked by the module.
///
/// Perhaps notably, calling this function before initializing Asar sets a flag
/// in Asar, which changes its API behavior slightly, but this module’s init()
/// always calls this function first, so this change cannot be observed.
pub fn api_version() -> i32 {
	unsafe {
		asar_apiversion() as i32
	}
}

/// Initialize Asar and check its API version.
///
/// This function checks if the Asar loaded reports the same API version as
/// this module expects. If it is too high (possibly incompatible) or too low
/// (also possibly incompatible) it immediately reports failure.
///
/// If the API version matches it calls Asar’s own initializer and reports
/// whether that failed or not.
///
/// Asar does not currently provide information about initialization beyond
/// whether it failed or succeeded.
#[must_use]
pub fn init() -> bool {
	// This call serves both to check version and to set an asar flag for
	// the API.
	let v = api_version();
	if v < EXPECTED_API_VER || v/100 > EXPECTED_API_VER/100 {
		false
	} else {
		/* asardll.c’s asar_init has a bunch of checks to make sure functions
		load. But rustc checks the symbols at link time, as long as they’re
		used in a function somewhere.
		Conveneniently, we have a wrapper function for each asar function, so
		they are all checked, and we can rely on the linker instead. */
		unsafe {
			asar_init() != 0
		}
	}
}

/// Resets Asar. Mostly useless.
///
/// Asar already resets most values itself when it begins patching -
/// otherwise matching labels would cause errors.
/// The only real uses would involve asar_resolvedefines, which is a deeply
/// dysfunctional routine to begin with and not yet supported by this module.
pub fn reset() -> bool {
	unsafe {
		asar_reset() != 0
	}
}

/// Reports Asar’s maximum allowed ROM size.
///
/// A signed C integer is provided by Asar but is expanded to usize because
/// its primary use is for initializing buffers.
pub fn max_rom_size() -> usize {
	unsafe {
		asar_maxromsize() as usize
	}
}

/// Performs Asar-style math operations on a string.
///
/// Depending on the last patch applied, may or may not include the xkas-style
/// lack of order-of-operations and uncomfortable rounding rules.
/// Note that Asar itself returns a double-precision float, for reasons unknowable.
pub fn math(expression: &str) -> Result<f64, String> {
	match CString::new(expression) {
		Ok(cs) => unsafe {
			let raw_s = cs.into_raw();
			let mut errs = ptr::null::<c_char>();
			let result = asar_math(raw_s, &mut errs);
			CString::from_raw(raw_s);
			if errs.is_null() {
				Ok(result)
			} else {
				Err(CStr::from_ptr(errs).to_string_lossy().into_owned())
			}
		},
		Err(_) => Err(format!("Invalid math string {:?}: contains NUL",
		                          expression))
	}
}

/// Applies a patch, from the given path, to the ROM in buffer.
///
/// This may result in the ROM being expanded.
/// After this, Asar keeps its set of labels and defines available until reset()
/// or patch() is called.
pub fn patch(path: &Path, rom: &mut RomBuf) -> AResult<()> {
	unsafe {
		let raw_path = CString::new(path.to_str().unwrap()).unwrap().into_raw();
		let mut size = rom.size as c_int;
		asar_patch(raw_path,
				   rom.buf.as_mut_ptr() as *mut c_char,
				   rom.buf.len() as c_int, &mut size);
		CString::from_raw(raw_path);

		let warns = all_warnings();
		match all_errors() {
			Some(errs) => Err((errs, warns)),
			None       => Ok(((), warns)),
		}
	}
}

/// Retrieves a label from the last applied patch.
///
/// Note that Asar returns this as a signed C integer, but it is expanded to
/// a usize because its primary use is as an address.
/// Also note that this provides a *mapped* address, the conversion of which
/// depends on the mapping used by the last applied patch.
pub fn label(name: &str) -> Option<usize> {
	if let Ok(cs_name) = CString::new(name) {
		unsafe {
			let raw_name = cs_name.into_raw();
			let v = asar_getlabelval(raw_name);
			CString::from_raw(raw_name);
			if v >= 0 {
				Some(v as usize)
			} else {
				None
			}
		}
	} else {
		None
	}
}

/// Provide’s Asar’s list of labels from the last applied patch.
///
/// Note that Asar provides psuedo-labels through as well,
/// such as the position +/- labels, under their ugly internal names.
/// This information is not sufficient to infer their parent label.
/// These labels are prefixed by ':' and may be ignored.
///
/// For more info see `asar::label`.
pub fn all_labels() -> HashMap<String, usize> {
	asar_map_convert(
		asar_getalllabels,
		|raw_label| { copy_asar_string(raw_label.name).unwrap() },
		|raw_label| { raw_label.location as usize },
	)
}

/// Returns a define from the last applied patch.
///
/// A define maps a string (its name) to another string (its value).
/// Its name must fit `[a-zA-Z0-9_]+`.
/// Note that this allows digits as the first character.
///
/// A define’s name is necessarily valid UTF-8 but its contents are not.
/// Currently, define values are therefore lossy, although Asar would
/// probably not accept the contents of any define lost.
pub fn define(name: &str) -> Option<String> {
	if let Ok(cs_name) = CString::new(name) {
		let v = unsafe {
			let raw_name = cs_name.into_raw();
			let v = asar_getdefine(raw_name);
			CString::from_raw(raw_name);
			v
		};
		copy_asar_string(v)
	} else {
		None
	}
}

/// Provides Asar’s list of defines from the last applied patch.
///
/// For more info see `asar::label`.
pub fn all_defines() -> HashMap<String, String> {
	asar_map_convert(
		asar_getalldefines,
		|raw_define| { copy_asar_string(raw_define.name).unwrap() },
		|raw_define| { copy_asar_string(raw_define.contents).unwrap() },
	)
}

/// Provides all printed strings from the last applied patch.
pub fn prints() -> Vec<String> {
	asar_array_convert(asar_getprints, |s| { copy_asar_string(*s).unwrap() })
}

fn all_errors() -> Option<Vec<AsmError>> {
	let v = asar_array_convert(asar_geterrors, one_error);
	if v.len() == 0 { None } else { Some(v) }
}

fn all_warnings() -> Vec<AsmError> {
	asar_array_convert(asar_getwarnings, one_error)
}

fn one_error(raw_err: &raw_errordata) -> AsmError {
	AsmError::Patch(
		PatchError {
			fulldata: copy_asar_string(raw_err.fullerrdata)
				.unwrap_or(String::from("<error decoding error>")),
			rawdata: copy_asar_string(raw_err.rawerrdata)
				.unwrap_or(String::from("<error decoding error>")),
			block: copy_asar_string(raw_err.block),
			filename: copy_asar_string(raw_err.filename)
				.unwrap_or(String::from("<unknown filename>")),
			caller_filename: copy_asar_string(raw_err.callerfilename),
			line: raw_err.line as i32,
			caller_line: if raw_err.callerline != 0 {
				Some(raw_err.callerline as i32)
			} else {
				None
			},
		}
	)
}

fn copy_asar_string(ptr: *const c_char) -> Option<String> {
	if ptr.is_null() {
		None
	} else {
		unsafe {
			Some(String::from(
				CStr::from_ptr(ptr).to_string_lossy().into_owned()
			))
		}
	}
}

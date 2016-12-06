#[derive(Debug)]
pub struct DysTables {
	pub sprite_sizes: usize,
	pub storage_ptrs: usize,
	pub option_bytes: usize,
	pub init_ptrs: usize,
	pub main_ptrs: usize,
	pub cls_ptrs: usize,
	pub xsp_ptrs: usize,
	pub mxs_ptrs: usize,
}

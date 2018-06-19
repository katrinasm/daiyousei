#[derive(Clone, Copy, Debug)]
pub struct InsertOpts {
    pub use_drops: bool,
    pub verbose: bool,
}

impl ::std::default::Default for InsertOpts {
    fn default() -> InsertOpts {
        InsertOpts {
            use_drops: false,
            verbose: false,
        }
    }
}


use std::fmt;
pub enum InsertError {
    AsmErr(::asar::AsmError),
    DysErr(String),
}

pub enum InsertWarning {
    AsmWarn(::asar::AsmError),
    DysWarn(String),
}

impl From<::asar::AsmError> for InsertError {
    fn from(err: ::asar::AsmError) -> InsertError {
        InsertError::AsmErr(err)
    }
}

impl From<String> for InsertError {
    fn from(s: String) -> InsertError {
        InsertError::DysErr(s)
    }
}

impl<'a > From<&'a str> for InsertError {
    fn from(s: &'a str) -> InsertError {
        InsertError::DysErr(s.to_string())
    }
}

impl From<::asar::AsmError> for InsertWarning {
    fn from(err: ::asar::AsmError) -> InsertWarning {
        InsertWarning::AsmWarn(err)
    }
}

impl From<String> for InsertWarning {
    fn from(s: String) -> InsertWarning {
        InsertWarning::DysWarn(s)
    }
}

impl<'a> From<&'a str> for InsertWarning {
    fn from(s: &'a str) -> InsertWarning {
        InsertWarning::DysWarn(s.to_string())
    }
}

impl fmt::Display for InsertError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            InsertError::AsmErr(ref a) => write!(f, "{}", a),
            InsertError::DysErr(ref d) => write!(f, "{}", d),
        }
    }
}

impl fmt::Display for InsertWarning {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            InsertWarning::AsmWarn(ref a) => write!(f, "{}", a),
            InsertWarning::DysWarn(ref d) => write!(f, "{}", d),
        }
    }
}

pub type InsertResult<T> = Result<
    (T, Vec<InsertWarning>),
    (Vec<InsertError>, Vec<InsertWarning>)
>;

pub fn format_result<T, E, F: FnOnce(E) -> String>(r: Result<T, E>, f: F)
-> InsertResult<T> {
    match r {
        Ok(v) => Ok((v, vec![])),
        Err(e) => Err((vec![f(e).into()], vec![])),
    }
}

pub fn warnless_result<T, E, F: FnOnce(E) -> String>(r: Result<T, E>, f: F)
-> Result<T, (Vec<InsertError>, Vec<InsertWarning>)> {
    r.map_err(|e| (vec![f(e).into()], vec![]))
}

pub fn single_error<T, E: Into<InsertError>>(err: E) -> InsertResult<T> {
    Err((vec![err.into()], vec![]))
}


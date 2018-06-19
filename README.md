# daiyousei
Daiyousei is a tool for inserting custom sprites into Super Mario World ROMs, intended as a
successor to mikeyk’s spritetool. Unlike previous efforts daiyousei strives for a high degree of
compatibility.


Also covered by this repo is `rsasar`, an interface for the Asar 65c816 assembler in Rust.
It is not in its own repo because it is not very good — in particular its design currently leads to
a really excessive amount of `unwrap()` calls surrounding address translation and the `Result`s are
weird, and because it is highly unlikely any other software will have use for it.
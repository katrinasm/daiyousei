incsrc "subroutine_prelude.asm"

namespace DYS_AUTOSPACE_FAFB6AB8
%ssr(Malloc)
	jml $03d6b0!F

%ssr(Free)
	jml $03d6b4!F


namespace DYS_AUTOSPACE_FAFB6AB9
!callZone = $01cd1e

%smw_ssr(DynAlloc, !callZone)
%smw_ssr(DynFree, !callZone+4)
%smw_ssr(DynUpload, !callZone+8)
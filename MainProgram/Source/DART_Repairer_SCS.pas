{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit DART_Repairer_SCS;

{$INCLUDE DART_defs.inc}

interface

uses
  AuxTypes,
  DART_Repairer;

const
  FileSignature_SCS = UInt32($23534353);

type
  TRepairer_SCS = class(TRepairer);

  TRepairer_SCS_Rebuild = class(TRepairer_SCS);
  TRepairer_SCS_Extract = class(TRepairer_SCS);

implementation

end.
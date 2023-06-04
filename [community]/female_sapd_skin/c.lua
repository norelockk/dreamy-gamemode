txd = engineLoadTXD ( "287.txd" )
engineImportTXD ( txd, 287 )
dff = engineLoadDFF ( "287.dff" )
engineReplaceModel ( dff, 287 )
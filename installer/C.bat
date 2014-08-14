del NpgsqlSetup.wixobj
del Npgsql-2.2.0.0-KU20140725-a846e688.wixpdb
del Npgsql-2.2.0.0-KU20140725-a846e688.msi
candle -dVER=2.2.0.0 -dEF=0 -ext WixUtilExtension NpgsqlSetup.wxs && light -ext WixUIExtension -ext WixUtilExtension NpgsqlSetup.wixobj -o Npgsql-2.2.0.0-KU20140725-a846e688.msi
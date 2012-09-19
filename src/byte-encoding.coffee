Iconv = require('iconv').Iconv
converter = new Iconv('UTF-8', 'ISO-8859-1')

exports.encode = (data) -> converter.convert(data)
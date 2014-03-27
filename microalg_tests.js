fs = require('fs')
function rec_read(filelist, e) {
    if (filelist.length > 0) {
        var filename = filelist.shift();
        fs.readFile(filename, 'utf8', function (err, content) {
            if (err) {
                return console.log(err);
            }
            if (filename.slice(-3) == '.js') {
                eval(content);
                rec_read(filelist, EMULISP_CORE);
            } else {
                e.eval(content);
                rec_read(filelist, e);
            }
        });
    }
}
rec_read(['emulisp/emulisp_core.js',
          'microalg.l', 'microalg_tests.malg']);

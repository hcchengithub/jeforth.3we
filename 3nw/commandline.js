
// 執行 node commandline.js 真的成功！
// http://nodejs.org/api/readline.html
// 可惜在 nw 下，process.stdin 是 "Error: Implement me. Unknown stdin file type!" 不知何故。
// hcchen5600 2013/11/05 21:23:51 

var readline = require('readline'),
    rl = readline.createInterface(process.stdin, process.stdout);

rl.setPrompt('OHAI> ');
rl.prompt();

rl.on('line', function(line) {
  switch(line.trim()) {
    case 'hello':
      console.log('world!');
      break;
    default:
      console.log('Say what? I might have heard `' + line.trim() + '`');
      break;
  }
  rl.prompt();
}).on('close', function() {
  console.log('Have a great day!');
  process.exit(0);
});

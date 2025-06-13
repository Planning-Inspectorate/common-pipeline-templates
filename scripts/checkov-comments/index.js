import {addCheckovComments, runCheckovCli} from './impl.js';

const args = process.argv.slice(2);
const checkovCmd = args[0];
const path = args[1];
const write = args[2] === '--write';

if (!checkovCmd || !path) {
    console.error('Usage: node index.js <checkovCmd> <path>');
    process.exit(1);
}

const results = await runCheckovCli(checkovCmd, path);
if (write) {
    console.log('adding comments to files...');
    await addCheckovComments(results, path);
    console.log('comments added');
}
console.log('done', results.length, 'checks found');

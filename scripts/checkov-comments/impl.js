import {exec} from 'node:child_process';
import { promisify } from 'node:util';
import {readFile, writeFile} from "fs/promises";
import path from 'node:path';

/**
 * @param {string} checkovCmd
 * @param {string} dir
 * @returns {Promise<CheckovResult[]>}
 */
export async function runCheckovCli(checkovCmd, dir) {
    const execAsync = promisify(exec);

    // could use a better output format, but this works OK
    const result = await execAsync(`${checkovCmd} -d ${dir} --framework terraform -o cli --quiet -s`);
    if (result.stderr) {
        console.error(result.stderr);
    }
    return parseCliResults(result.stdout);
}

/**
 * @param {CheckovResult[]} results
 * @param {string} dir
 * @returns {Promise<void>}
 */
export async function addCheckovComments(results, dir) {
    for (const result of results) {
        const {fileLines, checkDescription, filePath, checkId} = result;
        const fullPath = path.join(dir, filePath);
        const comment = `  #checkov:skip=${checkId}: ${checkDescription} (checkov v3)`;
        const lineNum = parseInt(fileLines[0], 10);
        console.log(`adding comment to ${filePath} after line ${lineNum}:\n  ${comment}`);

        const file = await readFile(fullPath, 'utf8');
        let lines = file.split('\n');
        if (lines[lineNum] === comment) {
            console.log(`comment already exists in ${filePath} at line ${lineNum}`);
            continue; // Skip if the comment already exists
        }
        lines = [
            ...lines.slice(0, lineNum),
            comment,
            ...lines.slice(lineNum)
        ];
        await writeFile(fullPath, lines.join('\n'), 'utf8');
    }
}

/**
 * @typedef {Object} CheckovResult
 * @property {string} checkId
 * @property {string} checkDescription
 * @property {string} filePath
 * @property {string[]} fileLines
 */

/**
 *
 * @param {string} results
 * @returns {CheckovResult[]}
 */
export function parseCliResults(results) {
    const seenResults = new Set();
    return results
        .split('Check:')
        .filter(Boolean)
        .filter((result) => !result.includes('terraform scan results'))
        .map((result) => {
            // crudely parse the output!
            const lines = result.trim().split('\n').map(line => line.trim());
            const checkLineParts = lines[0].trim().split(':');
            const checkId = checkLineParts[0].trim();
            const checkDescription = checkLineParts[1].trim().replace(/"/g, ''); // Remove quotes from description
            const fileInfo = lines.find(l => l.startsWith('File:')).trim();
            const fileParts = fileInfo.split(':');
            const filePath = fileParts[1].trim();
            const fileLines = fileParts[2].split('-');
            return { checkId, checkDescription, filePath, fileLines };
        })
        .filter(({checkId, filePath, fileLines}) => {
            const key = JSON.stringify({checkId, filePath, fileLines});
            if (seenResults.has(key)) {
                return false; // Skip duplicates
            }
            seenResults.add(key);
            return true;
        });
}
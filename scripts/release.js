import {execFileSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';

const TAG_PREFIX = 'release/';
const SEMVER_PATTERN = /^(\d+)\.(\d+)\.(\d+)$/;

function runGit(args) {
    return execFileSync('git', args, {encoding: 'utf8'}).trim();
}

export function stripReleasePrefix(tag) {
    return tag.startsWith(TAG_PREFIX) ? tag.slice(TAG_PREFIX.length) : tag;
}

export function parseVersion(version) {
    const match = version.match(SEMVER_PATTERN);
    if (!match) {
        throw new Error(`Invalid semantic version: ${version}`);
    }

    return {
        major: Number(match[1]),
        minor: Number(match[2]),
        patch: Number(match[3]),
    };
}

export function bumpVersion(version, releaseType) {
    const parsed = parseVersion(version);

    switch (releaseType) {
        case 'major':
            return `${parsed.major + 1}.0.0`;
        case 'minor':
            return `${parsed.major}.${parsed.minor + 1}.0`;
        case 'patch':
            return `${parsed.major}.${parsed.minor}.${parsed.patch + 1}`;
        default:
            throw new Error(`Unsupported release type: ${releaseType}`);
    }
}

export function getLatestReleaseTag() {
    const tags = runGit(['tag', '--list', `${TAG_PREFIX}*`, '--sort=-v:refname'])
        .split(/\r?\n/)
        .filter(Boolean);

    return tags[0] ?? null;
}

function getCommitsSince(tag) {
    const range = tag ? `${tag}..HEAD` : 'HEAD';
    const output = execFileSync('git', ['log', range, '--pretty=format:%s%n%b%x00'], {encoding: 'utf8'}).trim();

    if (!output) {
        return [];
    }

    return output
        .split('\u0000')
        .map((entry) => entry.trim())
        .filter(Boolean);
}

function classifyCommit(message) {
    const lines = message.split(/\r?\n/);
    const subject = lines[0]?.trim() ?? '';
    const body = lines.slice(1).join('\n');
    const conventionalMatch = subject.match(/^(\w+)(?:\([^)]*\))?(!)?:\s/);

    if (!conventionalMatch) {
        return null;
    }

    const type = conventionalMatch[1].toLowerCase();
    const isBreaking = Boolean(conventionalMatch[2]) || /^(BREAKING CHANGE|BREAKING CHANGES):/m.test(body);

    if (isBreaking) {
        return 'major';
    }

    if (type === 'feat') {
        return 'minor';
    }

    if (type === 'fix' || type === 'perf') {
        return 'patch';
    }

    return null;
}

export function determineReleaseType(messages) {
    let releaseType = null;

    for (const message of messages) {
        const commitType = classifyCommit(message);

        if (commitType === 'major') {
            return 'major';
        }

        if (commitType === 'minor') {
            releaseType = 'minor';
        }

        if (commitType === 'patch' && releaseType === null) {
            releaseType = 'patch';
        }
    }

    return releaseType;
}

function createReleaseTag(tag) {
    runGit(['tag', '-a', tag, '-m', tag]);
}

function main(argv) {
    const dryRun = argv.includes('--dry-run');
    const currentTag = getLatestReleaseTag();
    const currentVersion = currentTag ? stripReleasePrefix(currentTag) : '0.0.0';
    const commits = getCommitsSince(currentTag);
    const releaseType = determineReleaseType(commits);

    if (!releaseType) {
        console.log(`No release-worthy commits found since ${currentTag ?? 'the start of the repository'}.`);
        return;
    }

    const nextVersion = bumpVersion(currentVersion, releaseType);
    const nextTag = `${TAG_PREFIX}${nextVersion}`;

    console.log(`Current version: ${currentVersion}`);
    console.log(`Next version:    ${nextVersion}`);
    console.log(`Release tag:     ${nextTag}`);

    if (dryRun) {
        console.log('Dry run only; no tag created.');
        return;
    }

    createReleaseTag(nextTag);
    console.log(`Created tag ${nextTag}`);
}

const entryPoint = process.argv[1] ? pathToFileURL(process.argv[1]).href : null;

if (import.meta.url === entryPoint) {
    try {
        main(process.argv.slice(2));
    } catch (error) {
        console.error(error instanceof Error ? error.message : error);
        process.exit(1);
    }
}


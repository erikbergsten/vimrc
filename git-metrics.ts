import { readFile } from 'fs/promises';
import { promisify } from 'node:util';
import { exec } from 'node:child_process';
import { program } from 'commander';

const PRETTY_FMT = `---%n%cs %s`
const LOG_CMD = `git --no-pager log --numstat --pretty="${PRETTY_FMT}"`

function sum(a: number, b: number): number { return a + b }

type Change = {
  file: string,
  insertions: number,
  deletions: number
}

function readChange(line: string): Change {
  const [ insertions, deletions, file] = line.split('\t')
  return {
    file,
    insertions: parseInt(insertions),
    deletions: parseInt(deletions)
  }
}

class Commit {
  date: Date
  message: string
  changes: Change[]
  constructor(lines: string[]) {
    const [ date, message ] = lines[0].split(/ (.*)/)
    if(lines[1] !== '') {
      throw new Error(`bad second line in commit ${message}: ${lines[1]}`)
    }
    this.date = new Date(date),
    this.message = message
    this.changes = lines.slice(2).map( readChange )
  }

  static tryCreate(lines: string[]): Commit | undefined {
    let commit = undefined
    try {
      commit = new Commit(lines)
    } catch (e) {
      console.error(e.message)
    }
    return commit
  }

  insertions(): number {
    return this.changes
      .map((change: Change) => change.insertions)
      .reduce(sum, 0)
  }

  deletions(): number {
    return this.changes
      .map((change: Change) => change.deletions)
      .reduce(sum, 0)
  }

  toString(): string {
    return `[${this.date}]: ${this.message} (${this.insertions()}/${this.deletions()})`
  }

}

type CommitSizeOptions = {
  start?: string,
  end?: string,
  json?: boolean
}

async function commitSize({start, end, json}: CommitSizeOptions) {
  const { stdout } = await promisify(exec)(LOG_CMD)
  let commits = stdout
    .split('\n')
    .reduce( (acc: [string[], string[]], value: string) => {
      const [groups, current] = acc
      if(value === '---') {
        return [[...groups, current], []]
      } else {
        return [groups, [...current, value]]
      }
    }, [[], []])
    .at(0)
    .slice(1)
    .map(Commit.tryCreate)
    .filter((x: Commit | undefined) => x !== undefined)

  if(start !== undefined) {
    const startDate = new Date(start)
    commits = commits
      .filter((commit: Commit) => commit.date > new Date(start))
  }

  if(end !== undefined) {
    const endDate = new Date(end)
    commits = commits
      .filter((commit: Commit) => commit.date < new Date(end))
  }

  const nCommits = commits.length
  const insertions = commits
    .map((commit: Commit) => commit.insertions())
    .reduce(sum, 0)
  const deletions = commits
    .map((commit: Commit) => commit.deletions())
    .reduce(sum, 0)

  if(json) {
    console.log(JSON.stringify({
      commits: nCommits,
      insertions,
      deletions,
      avg: {
        insertions: insertions/nCommits,
        deletions: deletions/nCommits
      }
    }))
  } else {
    console.log(`Commits: ${nCommits}, insertions: ${insertions}, deletions: ${deletions}`)
    console.log(`Average insertions/deletions: ${insertions/nCommits}, ${deletions/nCommits}`);
  }
}

program
  .name('git-metrics')
  .description('GIT Metric Extraction ToolKit of doom')
  .version('0.1.0')

program.command('commit-size')
  .description('Count the number insertions/deletions per commit')
  .option('--start <string>', 'start date (iso 8601 string)')
  .option('--end <string>', 'end date (iso 8601 string)')
  .option('-j, --json', 'output as json object')
  .action((opts: CommitSizeOptions) => {
    commitSize(opts)
  })

program.parse()

"""gitlog2changelog.py

Usage:
  gitlog2changelog.py
  gitlog2changelog.py (-h | --help)
  gitlog2changelog.py --version

Options:
  -h --help     Show this screen.
  --version     Show version.
  --beginning=<tag> Where in the History to begin

"""

import re

from git import Repo
from docopt import docopt
from github import Github


def get_github_user_for_pr(pr_number):
    ghrepo = Github("").get_repo("numba/numba")
    return ghrepo.get_issue(pr_number)


if __name__ == '__main__':
    arguments = docopt(__doc__, version='1.0')
    beginning = "0.54.0dev0"
    repo = Repo('.')
    rawgit = repo.git
    all_commits = [x for x in repo.iter_commits('0.54.0dev0..HEAD')]
    merge_commits = [x for x in all_commits
                     if 'Merge pull request' in x.message]
    prmatch = re.compile('^Merge pull request #([0-9]{4}) from.*')
    auth_id = re.compile('^Merge pull request #([0-9]{4}) from (.*)\/.*\\n.*')
    ordered = {}
    authors = set()
    for x in merge_commits:
        match = prmatch.match(x.message)
        if match:
            issue_id = match.groups()[0]
            ordered[issue_id] = "%s" % (x.message.splitlines()[2])
    for x in all_commits:
        authors.add(x.author.name)
    print("Commits:")
    for k in sorted(ordered.keys()):
        issue = get_github_user_for_pr(int(k))
        hyperlink = "`#%s <%s>`_" % (k, issue.html_url)
        user = "`%s <%s>`_" % (issue.user.name
                               if issue.user.name is not None
                               else issue.user.login , issue.user.html_url)
        print("* PR %s: %s (%s)" % (hyperlink, ordered[k], user))
    print("Total PRs: %s" % len(ordered))
    print("")
    print("Authors:")
    [print('* %s' % x) for x in sorted(authors)]
    print("Total authors: %s" % len(authors))

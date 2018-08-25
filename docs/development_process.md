# Development process

1. Find a ticket from the top of `To Do` column on [Active Development (Kanban board)](https://github.com/LocalOrbit/localorbit/projects/1)
1. Assign it to yourself
1. Move it to `In progress`
1. Create a feature branch off master
1. Do the work
1. Get all tests green locally
1. Push branch to `origin`, eg. `git push -u origin my_feature_branch`
1. Check automated tests for branch pass (no conflicts, CircleCI, RuboCop)
1. Create a PR
1. Move ticket to `Needs review` on [Kanban board](https://github.com/LocalOrbit/localorbit/projects/1)
1. Get PR reviewed and approved
1. Merge down to `master`
1. Discuss if it's a reasonable time to merge to staging
1. Merge to `staging`
1. Move ticket to `Awaiting QA` on [Kanban board](https://github.com/LocalOrbit/localorbit/projects/1)
1. Communicate with team about test plan for new stuff on staging
1. Move tickets to `QA Accepted` on [Kanban board](https://github.com/LocalOrbit/localorbit/projects/1)
1. Release manager checks with team that we're good to promote staging to production
1. Merge `staging` to `production`
1. Create a tag, Eg. `git tag -a v5.0.3 -m 'An annotated tag'`
1. Go into [semaphore](https://semaphoreci.com/micah/localorbit) and do a [manual deploy](#)
1. Sanity check on production that core flows work, and review features
1. Release manager moves tickets from `QA Accepted` to `Released`
1. Delete feature branches once they are in the tag

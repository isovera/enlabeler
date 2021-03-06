# Enlabeler

Enlabeler is a script that adds, updates and removes the labels for a GitHub issue queue based on a standardized configuration file. Inspired by [this style guide](https://robinpowered.com/blog/best-practice-system-for-organizing-and-tagging-github-issues/), Enlabeler's opinions are based on [Drupal](https://www.drupal.org/) website design and development and organize issue labels into the following groups:

- _Priority Level_ - level of urgency for a given issue
- _Status_ - status of work on the issue
- _Job Type_ - category of work required to complete the issue
- _DevOps_ - issues related to deployment and external infrastructure
- _Planning_ - project management and planning work
- _Supplementary_ - any additional technical or related information for the issue 

## Prerequisites

You will need the following to execute this script:

- GitHub user account
- GitHub personal access token, if you have two factor authentication enabled.
  See [Creating a personal access token for the command line](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).
- Clone this repository or copy `enlabeler.sh`  to your local environment.
- Install [jq](https://stedolan.github.io/jq/) (on MacOS with [Homebrew](https://brew.sh/), use the command `brew install jq`).

## To Use

1. Clone the repository.
2. Modify `label-info.json` as necessary.
3. Open your terminal in the same directory as this script and execute the script: `./enlabeler.sh`
4. Follow the instructions within the script.

## Label Groups

Enlabeler groups issue labels by color and description prefixes as shown in the table below. High priority and blocking-related labels are exceptions to the standard color scheme, and are given additional contrast to increase their salience.

Group | Subgroup | Label |
--- | --- | ---
Priority Level | | ![priority: critical](https://labl.es/svg?text=priority:%20critical&bgcolor=9F0000) ![priority: high](https://labl.es/svg?text=priority:%20high&bgcolor=E30303) ![priority: medium](https://labl.es/svg?text=priority:%20medium&bgcolor=ff6666) ![priority: low](https://labl.es/svg?text=priority:%20low&bgcolor=ffb3b3) 
Status | | ![blocked](https://labl.es/svg?text=blocked&bgcolor=1C6F87) ![blocker](https://labl.es/svg?text=blocker&bgcolor=1C6F87) ![stalled](https://labl.es/svg?text=stalled&bgcolor=8edee7) ![question](https://labl.es/svg?text=question&bgcolor=8edee7) ![needs revision](https://labl.es/svg?text=needs%20revision&bgcolor=8edee7)  ![needs estimate](https://labl.es/svg?text=needs%20estimate&bgcolor=8edee7) ![has workaround](https://labl.es/svg?text=has%20workaround&bgcolor=8edee7) ![changes requested](https://labl.es/svg?text=changes%20requested&bgcolor=8edee7) ![duplicate](https://labl.es/svg?text=duplicate&bgcolor=8edee7) ![recommendation](https://labl.es/svg?text=recommendation&bgcolor=8edee7)
Job Type | Front-end | ![pattern](https://labl.es/svg?text=pattern&bgcolor=a8d49a) ![theming](https://labl.es/svg?text=theming&bgcolor=a8d49a)
Job Type | Back-end | ![migration](https://labl.es/svg?text=migration&bgcolor=dbff89) ![drupal](https://labl.es/svg?text=drupal&bgcolor=dbff89)
Job Type | Design | ![ux/design](https://labl.es/svg?text=ux/design&bgcolor=f8ff84)
Job Type | Content | ![content](https://labl.es/svg?text=content&bgcolor=ffeb6d) ![translation](https://labl.es/svg?text=translation&bgcolor=ffeb6d) ![post-migration](https://labl.es/svg?text=post-migration&bgcolor=ffeb6d)
Job Type | Other | ![documentation](https://labl.es/svg?text=documentation&bgcolor=ffdd00)
DevOps | | ![deployment](https://labl.es/svg?text=deployment&bgcolor=ffa64d) ![has manual deployment](https://labl.es/svg?text=has%20manual%20deployment&bgcolor=ffa64d) ![hotfix](https://labl.es/svg?text=hotfix&bgcolor=ffa64d) ![infastructure](https://labl.es/svg?text=infastructure&bgcolor=ffa64d)
Planning | | ![epic](https://labl.es/svg?text=epic&bgcolor=fba4e4) ![sprint planning](https://labl.es/svg?text=sprint%20planning&bgcolor=fba4e4) ![retrospectice](https://labl.es/svg?text=retrospective&bgcolor=fba4e4) ![user story](https://labl.es/svg?text=user%20story&bgcolor=fba4e4) ![revise issue](https://labl.es/svg?text=revise%20issue&bgcolor=fba4e4)
Supplementary | | ![security](https://labl.es/svg?text=security&bgcolor=98aeff) ![seo](https://labl.es/svg?text=seo&bgcolor=98aeff) ![social](https://labl.es/svg?text=social&bgcolor=98aeff) ![multilingual](https://labl.es/svg?text=multilingual&bgcolor=98aeff) ![performance](https://labl.es/svg?text=performance&bgcolor=98aeff) ![x-browser: ie10](https://labl.es/svg?text=x-browser:%20ie10&bgcolor=98aeff) ![x-browser: ie11](https://labl.es/svg?text=x-browser:%20ie11&bgcolor=98aeff) ![x-browser: edge](https://labl.es/svg?text=x-browser:%20edge&bgcolor=98aeff)![maintenance program](https://labl.es/svg?text=maintenance%20program&bgcolor=98aeff) ![discovery](https://labl.es/svg?text=discovery&bgcolor=98aeff) ![search](https://labl.es/svg?text=search&bgcolor=98aeff)


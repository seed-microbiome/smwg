# Web pages for the 'Seed Microbiome Working Group'

This web page uses Jekyll through GitHub pages which renders static HTML pages that are accessible at [https://seed-microbiome.github.io/smwg/](https://seed-microbiome.github.io/smwg/). The layout should auto-support various screen sizes etc. through bootstrap.

To install Jekyll locally, follow: [https://jekyllrb.com/docs/installation/](https://jekyllrb.com/docs/installation/).

## Maintaining / Updating

All content is decoupled from the HTML/layout and should be edited in `_config.yml` and `_data/talks.yml`. Speaker photos should go in `assets/speakers/` if available.

## Previewing / Running locally

You will need to install Jekyll on your machine first. After that you can clone this repository, checkout the `gh-pages` branch, and run the following:

    jekyll serve --baseurl ""

Where the `--baseurl` option overwrites the GitHub-specific path, and makes the page preview available (typically) at http://127.0.0.1:4000/

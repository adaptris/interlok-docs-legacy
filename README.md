# IMPORTANT

- This project will be archived since we have moved to [docsify](https://docsify.js.org/#/)

# Interlok Documentation

- The documentation once generated is FLAT.
    - the name of the file in the permalink must match your filename.
    - No namespaces, which is why I have prefixed effectively the dir name to the filename.
    - This might break existing links. Do check your page.

- You can link images either the traditional way, or check index.md which uses the image_link
    - If traditional, then make sure you use ./images/XXX/blah.png
- Modify _data/sidebars/home_sidebar.yml to add your page.
    - If you want a new "section" then just add one

- Create your page in your ./pages

- If you want a new tag then you need to
    - Add your tag name to _data/tags.yml
    - Add a new page in tags/ copy and paste an existing one and modify it appropriately.

The jekyll theme is : http://idratherbewriting.com/documentation-theme-jekyll/index.html that contains all the info you will need.

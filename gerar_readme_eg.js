/**
 * Copyright (c) 2017, Micael Levi
 *
 * Exemplo de uso do template definido em EJS
 * para gerar um boilerplate do README.md padrão.
 * params: <nome-linguagem> <cor-emblema> <caminho-pra-logo>
 *
 * Requer o NodeJs e o NPM:
 * $ npm install ejs
 * $ node gerar_readme_eg.js Elixir 6E4A7E https://techsquare.co/wp-content/uploads/2017/08/1481354.png
 * $ cat __README.md
 */

const ejs = require('ejs')
const [ ,, name, badge_color, logo_path ] = process.argv

// ------------------------------------------- //
const lang = {
  name,
  badge_color, // from https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml
  badge_width: 180,
  logo_path,
  logo_width: 160,
}

const sections = [
  { name: 'Vídeos', emoji: 'video_camera' },
  { name: 'Screencasts e Relacionados', emoji: 'floppy_disk' },
  { name: 'Artigos e Relacionados', emoji: 'newspaper' },
  { name: 'Livros', emoji: 'books' },
]
// ------------------------------------------- //

const templateMD = `
<div align="center">
  <img src="<%= lang.logo_path %>" width="<%= lang.logo_width %>">
  <h1><i><%= lang.name %></i> de Cada Dia</h1>
  <img src="https://img.shields.io/badge/done-0%25%20(0%20of%200)-<%= lang.badge_color %>.svg" width="<%= lang.badge_width %>">
</div>

<p align="center">
<% sections.forEach(function(s) { -%>
  <a href="#<%= s.name.trim().toLowerCase().replace(/\\s/g, '-') %>">:<%= s.emoji %>:</a>&nbsp;
<% }) -%>
</p>

---

<div align="center">


<% sections.forEach(function(section) { -%>
## <%= section.name %>

status | title | last update | snnipet | notes
:-----:|:------|:-----------:|:-------:|:----:


<% }) -%>
</div>
`

if (lang.name) {
  const rendered = ejs.render(templateMD.trimLeft(), { lang, sections })
  console.log(rendered)
  require('fs').writeFileSync('__README.md', rendered);
}

/**
 * Exemplo de uso do template definido para gerar um
 * boilerplate do README.md para a linguagem de programação Elixir.
 *
 * Requer o NodeJs...
 * $ npm install ejs
 * $ node gerar_readme.js
 * $ cat README-gerado.md
 */

const ejs = require('ejs');

// ------------------------------------------- //
const brAmount = 4;
const lang = {
  name: 'Elixir',
  githubcolor: '6E4A7E', // from https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml
  logo: {
    path: 'https://techsquare.co/wp-content/uploads/2017/08/1481354.png',
    width: 160
  }
};
const sections = ['## Youtube', '### playlists', '## outros', '## livros/artigos'];
// ------------------------------------------- //

const templateMD = `<img src="<%= lang.logo.path %>" width="<%= lang.logo.width %>" align="right">
<% for (let i=0; i < brAmount; ++i) { -%>
<br>
<% } -%>

# _<%= lang.name %>_ de Cada Dia
<img src="https://img.shields.io/badge/done-0%25%20(0%20of%200)-<%= lang.githubcolor %>.svg" width="200" align="right">
<br>


<%= sections.join("\\n\\n"); %>
`;

require('fs').writeFileSync('README-gerado.md', ejs.render(templateMD, { lang, brAmount, sections }));

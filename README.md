# `X` de Cada Dia

1. **onde** [**X =** Clojure(Script)](./clojure/README.md)
2. **onde** [**X =** Ruby](./ruby/README.md)
3. **onde** [**X =** Elixir](./elixir/README.md)
4. **onde** [**X =** Go](./go/README.md)

## Formatação para Uso
Para o correto funcionamento dos scripts desenvolvidos para "automatizar" a atualização das tarefas,
o arquivo texto **em Markdown** que lista tais tarefas _("README.md" por padrão)_ deve seguir o template <a href="http://ejs.co" title="Effective JavaScript templating">EJS</a> abaixo. Além disso, os itens que serão chamados de "tarefas" devem estar dipostos um por linha da seguinte forma:

```markdown
- [ ] [TÍTULO-DA-TAREFA](LINK-DE-REFERÊNCIA-PARA-A-TAREFA) <!-- tarefa pendente -->
- [x] [TÍTULO-DA-TAREFA](LINK-DE-REFERÊNCIA-PARA-A-TAREFA) <!-- tarefa concluída -->
  > * descrição opcional
```

```ejs
<img src="<%= lang.logo.path %>" width="<%= lang.logo.width %>" align="right">
<% for (let i=0; i < brAmount; ++i) { -%>
<br>
<% } -%>

# _<%= lang.name %>_ de Cada Dia
<img src="https://img.shields.io/badge/done-0%25%20(0%20of%200)-<%= lang.githubcolor %>.svg" width="200" align="right">
<br>


<%= sections.join("\\n\\n"); %>
```

```js
brAmount: Number;
lang: {
  name: String,
  githubcolor: String,
  logo: { path: String, width: Number }
};
sections: [String];
```
<div align="right">
  <small>
    um exemplo de uso pode ser visto em <a href="./gerar_readme_eg.js">gerar_readme_eg.js</a>.
  </small>
</div>
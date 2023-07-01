# Template Inheritance

Source: https://guides.rubyonrails.org/layouts_and_rendering.html#template-inheritance

The lookup order for an admin/products#index action will be:

```
app/views/admin/products/
app/views/admin/
app/views/application/
```

This makes app/views/application/ a great place for your shared partials, which can then be rendered in your ERB as such:

```
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
There are no items in this list <em>yet</em>.
```

### Personal Thoughts

I don't like this, I prefer a specific folder `shared`.

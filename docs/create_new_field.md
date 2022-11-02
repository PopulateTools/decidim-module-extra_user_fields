# Create a new extra user field

Follow these steps to create a extra user field in the module.

## Getting started

In this example we will create an acceptance checkbox where user must have the required age to register.

1. Create a new attribute in forms_definitions

Form contains attributes given to the HTML form and ensure field validations.

In `app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb` add your new attribute between comments "#Block ExtraUserFields" and "#EndBlock"

```ruby
# File: app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb

#Block ExtraUserFields Attributes
attribute :minimum_age, Virtus::Attribute::Boolean
#EndBlock

#Block ExtraUserFields Validations
validates :minimum_age, acceptance: true, if: :minimum_age?
#EndBlock
```

In the same file, update the method `map_model` with your new field

```ruby
# File: app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb

#Block ExtraUserFields MapModel
self.minimum_age = extended_data[:minimum_age]
#EndBlock
```

Then create a method to toggle attribute in form in function of admin choices
```
# File: app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb

#Block ExtraUserFields EnableFieldMethod
def minimum_age?
    extra_user_fields_enabled && current_organization.activated_extra_field?(:minimum_age)
end
#EndBlock
```

Nice your form is ready ! 

2. Let's update the registration system spec

If you don't update specs, continuous integration will fail...

Open file `spec/system/registration_spec.rb` and add your new field in extra_user_fields variable

```ruby
# File: spec/system/registration_spec.rb

#Block ExtraUserFields ExtraUserFields
"minimum_age" => minimum_age,
#EndBlock
```

Then create the rspec variable in same file

```ruby
# File: spec/system/registration_spec.rb

#Block ExtraUserFields RspecVar
let(:minimum_age) do
  { "enabled" => true }
end
#EndBlock
```

Check presence of your field in spec

```ruby
# File: spec/system/registration_spec.rb

#Block ExtraUserFields ContainsFieldSpec
expect(page).to have_content("Minimum age")
#EndBlock
```

Check that field is mandatory
```ruby
# File: spec/system/registration_spec.rb

#Block ExtraUserFields ItBehavesLikeSpec
it_behaves_like "mandatory extra user fields", "minimum_age"
#EndBlock
```

Check that field disappear when extra user fields is disabled
```ruby
# File: spec/system/registration_spec.rb

#Block ExtraUserFields DoesNotContainFieldSpec
expect(page).not_to have_content("Minimum age")
#EndBlock
```

3. Once system spec ready, let's make it pass

Add your new field in the registration form HTML file

```HTML
# File: app/views/decidim/extra_user_fields/_registration_form.html.erb

<%# Block ExtraUserFields SignUpFormFields %>
<% if current_organization.activated_extra_field?(:minimum_age) %>
<div class="field">
    <%= f.check_box :minimum_age %>
</div>
<% end %>
<%# EndBlock %>
```

Now the field `check_box minimum_age` refers to the attribute previously defined in `app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb:20`

We must now ensure that field is saved in user extended data.

In file `app/commands/concerns/decidim/extra_user_fields/commands_overrides.rb`, add your new field

```ruby
# File: app/commands/concerns/decidim/extra_user_fields/commands_overrides.rb

#Block ExtraUserFields SaveInExtendedData
minimum_age: @form.minimum_age,
#EndBlock
```

In the example above, trailing comma is important or it could occur synthax error in future.

**Now your new field is available in the signup form and saved in user extended data !**


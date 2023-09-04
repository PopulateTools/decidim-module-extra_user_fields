# Create a new extra user field

Let's see how to create a new extra user field in the module using TDD method. For the example, we will create a simple checkbox that must be checked. For the tutorial, field will be `minimum_age` and must be check by user on registration.



# Table of Contents
1. [Create field in registration form](#registration-form)
2. [Create field in user account form](#account-form)
3. [Add your new field to the user exports](#exports)
4. [Allow admins to enabled / disable your field from backoffice](#backoffice)


## Getting started

This guide contains multiple steps, please ensure to be attentive to the name of files and refers to the comments to help you.

## Create field in registration form <a name="registration-form"></a>

### Create a new attribute in form

Form contains attributes given to the HTML form and ensure field validations.

1. Add new attribute and validations to the form

In `app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb` add your new attribute between comments "#Block ExtraUserFields" and "#EndBlock"

```ruby
# File: app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb

#Block ExtraUserFields Attributes
attribute :minimum_age, Boolean
#EndBlock

#Block ExtraUserFields Validations
validates :minimum_age, acceptance: true, presence: true, if: :minimum_age?
#EndBlock
```

2. Define your new field in the `map_model` method

In the same file, update the method `map_model` with your new field

```ruby
# File: app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb

#Block ExtraUserFields MapModel
self.minimum_age = extended_data[:minimum_age]
#EndBlock
```

3. Create custom validation for your new attribute

Then create a method to toggle attribute in form in function of admin choices
```
# File: app/forms/concerns/decidim/extra_user_fields/forms_definitions.rb

#Block ExtraUserFields EnableFieldMethod
def minimum_age?
    extra_user_fields_enabled && current_organization.activated_extra_field?(:minimum_age)
end
#EndBlock
```

**Nice your form is ready !**

### Add a new field in the registration form

1. Update the registration system spec

_If you don't update specs, continuous integration will fail..._

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

#Block ExtraUserFields FillExtraUserFields
check :registration_user_minimum_age
#EndBlock
```


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

2. Add your new field in the registration form HTML file

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

3. Save your new field in the user extended data

In file `app/commands/concerns/decidim/extra_user_fields/commands_overrides.rb` and in file `app/commands/concerns/decidim/extra_user_fields/omniauth_commands_overrides.rb` , add your new field

```ruby
# File: app/commands/concerns/decidim/extra_user_fields/commands_overrides.rb

#Block ExtraUserFields SaveInExtendedData
minimum_age: @form.minimum_age,
#EndBlock
```

```ruby
# File: app/commands/concerns/decidim/extra_user_fields/omniauth_commands_overrides.rb

#Block ExtraUserFields SaveInExtendedData
minimum_age: @form.minimum_age,
#EndBlock
```

In the example above, trailing comma is important or it could occur synthax error in future.

**Now your new field is available in the signup form and saved in user extended data !**

## Create field in the user account form<a name="account-form"></a>

1. Add system specs for account form in `spec/system/account_spec.rb`

Add your field to the `extra_user_fields` Hash
```ruby
# File: spec/system/account_spec.rb

#Block ExtraUserFields ExtraUserFields
"minimum_age" => minimum_age,
#EndBlock
```

And create the missing Rspec variable

```ruby
# File: spec/system/account_spec.rb

#Block ExtraUserFields RspecVar
let(:minimum_age) do
  { "enabled" => true }
end
#EndBlock
```

Now we can ensure field is present and selectable

```ruby
# File: spec/system/account_spec.rb

#Block ExtraUserFields FillFieldSpec
check :user_minimum_age
#EndBlock
```

2. Add field to the account form

Once tests are added to the account system file, you can define your field in the account form

```HTML
# File: app/views/decidim/extra_user_fields/_profile_form.html.erb

<%# Block ExtraUserFields AccountFormFields %>
<% if current_organization.activated_extra_field?(:minimum_age) %>
  <%= f.check_box :minimum_age %>
<% end %>
<%# EndBlock %>
```

**You should now see your new field in the account form !**

## Add your new extra user field to the user exports<a name="exports"></a>

1. Add your field to the user exports

First of all, let's define your field in the serializer specs 

```ruby
# File: spec/serializers/user_export_serializer_spec.rb


#Block ExtraUserFields ExtraUserFields
minimum_age: minimum_age,
#EndBlock
```

```ruby
# File: spec/serializers/user_export_serializer_spec.rb

#Block ExtraUserFields RspecVar
let(:minimum_age) { true }
#EndBlock
```

And add an inclusion test for your field


```ruby
# File: spec/serializers/user_export_serializer_spec.rb


#Block ExtraUserFields IncludeExtraField
it "includes the minimum_age" do
  expect(serialized).to include(minimum_age: resource.extended_data["minimum_age"])
end
#EndBlock
```

2. Then add it to the serializer

```ruby
# File: app/serializers/decidim/extra_user_fields/user_export_serializer.rb

#Block ExtraUserFields AddExtraField
:minimum_age,
#EndBlock
```

## Allow admin to enable / disable your new field in backoffice<a name="backoffice"></a>

1. Add your new field to the admin extra user field form

```ruby
# File: app/forms/decidim/extra_user_fields/admin/extra_user_fields_form.rb

#Block ExtraUserFields Attributes
attribute :minimum_age, Boolean
#EndBlock
```

2. Add it to the `map_model` method of the same file

```ruby
# File: app/forms/decidim/extra_user_fields/admin/extra_user_fields_form.rb

#Block ExtraUserFields MapModel
self.minimum_age = model.extra_user_fields.dig("minimum_age", "enabled")
#EndBlock
```

3. Now we can add it to the command to save it in organization's configs

First we add the spec in `spec/commands/decidim/extra_user_fields/admin/update_extra_user_fields_spec.rb`

```ruby
# File: spec/commands/decidim/extra_user_fields/admin/update_extra_user_fields_spec.rb

#Block ExtraUserFields RspecVar
let(:minimum_age) { true }
#EndBlock

#Block ExtraUserFields ExtraUserFields
"minimum_age" => minimum_age,
#EndBlock

#Block ExtraUserFields InclusionSpec
expect(extra_user_fields).to include("minimum_age" => { "enabled" => true })
#EndBlock

```

And add it to the command to make it pass

```ruby
# File: app/commands/decidim/extra_user_fields/admin/update_extra_user_fields.rb

#Block ExtraUserFields SaveFieldInConfig
"minimum_age" => { "enabled" => form.minimum_age.presence || false },
#EndBlock
```

4. Now we create the field in settings form

```HTML
# File: app/views/decidim/extra_user_fields/admin/extra_user_fields/_form.html.erb

<%# Block ExtraUserFields ExtraFields %>
<%= render partial: "decidim/extra_user_fields/admin/extra_user_fields/fields/minimum_age", locals: { form: form } %>
<%# EndBlock %>
```

5. Create a new partial file for your new file

```
touch app/views/decidim/extra_user_fields/admin/extra_user_fields/fields/_minimum_age.html.erb

# File: app/views/decidim/extra_user_fields/admin/extra_user_fields/fields/_minimum_age.html.erb

<div class="card-section">
  <div class="row column">
    <p><%= t(".description") %></p>
    <%= form.check_box :minimum_age, label: t(".label") %>
  </div>
</div>
```

6. Then in locales, add your translations

```yaml
en:
  decidim:
    extra_user_fields:
      admin:
        extra_user_fields:
          fields:
            minimum_age:
              description: This field requires to be checked
              label: Enable minimum age field
```


**Nice ! It should be good now !**

$(document).ready(function() {
    const underageCheckbox = $('#registration_underage_checkbox');
    const statutoryRepresentativeEmailField = $('#statutory_representative_email_field');
    const dateOfBirthField = $('#registration_user_date_of_birth');
    const underageFieldSet = $('#underage_fieldset');
    let underageLimit = 18;

    // Function to show or hide underage related fields based on age
    function updateUnderageFields() {
        const dobValue = dateOfBirthField.val();
        //const dobParts = dobValue.split('-');
        //const dobDate = Date.parse(`${dobParts[1]}-${dobParts[0]}-${dobParts[2]}`);
        const dobDate = Date.parse(`${dobValue}`)
        const currentDate = Date.now();
        const ageInMilliseconds = currentDate - dobDate;
        const age = Math.abs(new Date(ageInMilliseconds).getUTCFullYear() - 1970);

        if (age < underageLimit) {
            underageFieldSet.removeClass('hidden');
            underageCheckbox.prop('checked', true);
            statutoryRepresentativeEmailField.removeClass('hidden');
        } else {
            statutoryRepresentativeEmailField.find('input').val('');
            underageFieldSet.addClass('hidden');
            underageCheckbox.prop('checked', false);
            statutoryRepresentativeEmailField.addClass('hidden');
        }
    }

    if (underageCheckbox.length && statutoryRepresentativeEmailField.length) {
        underageCheckbox.on('change', function() {
            if (underageCheckbox.prop('checked')) {
                statutoryRepresentativeEmailField.removeClass('hidden');
            } else {
                statutoryRepresentativeEmailField.find('input').val('');
                statutoryRepresentativeEmailField.addClass('hidden');
            }
        });
    }

    if (dateOfBirthField.length && underageCheckbox.length) {
        updateUnderageFields();
    }

    if (underageCheckbox.length) {
        $.ajax({
            url: '/extra_user_fields/underage_limit', // Updated to match the new route
            type: 'GET',
            success: function (data) {
                underageLimit = data.underage_limit;
                if (dateOfBirthField.length && underageFieldSet.length) {
                    updateUnderageFields();
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.error("Failed to fetch underage limit:", textStatus, errorThrown);
            }
        });
    }

    if (dateOfBirthField.length && underageFieldSet.length) {
        dateOfBirthField.on('change', function() {
            updateUnderageFields();
        });
    }
});

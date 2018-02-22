;(function($, undefined) {
  $(function() {

    function showSuborders(button, form) {
      form.find('.order-details').removeClass('is-hidden');
      form.find('.pay-all-now').addClass('is-invisible');
      button.html('Hide Orders');
      showSuborderPaymentUI(form);
    }

    function hideSuborders(button, form) {
      form.find('.order-details').addClass('is-hidden');
      form.find('.pay-all-now').removeClass('is-invisible');
      button.html('Review');
      showSuborderPaymentUI(form);
    }

    function showSuborderPaymentUI(form) {
      form.find('.pay-selected-now').removeClass('is-hidden');
      form.find('.payment-details').addClass('is-hidden');
    }

    $('.vendor-payment .review-orders').click(function(e) {
      e.preventDefault();
      var form, button, orderDetails;
      button = $(this);
      form = button.parents('form');
      orderDetails = form.find('.order-details');
      button.prop('disabled', true);

      if (orderDetails.is(':hidden')) {
        if (orderDetails.find('tr').length === 0) {
          button.html('Retrieving ...');
          $.get($(this).data('href'), function(data) {
            orderDetails.html(data);
            showSuborders(button, form);
          });
        } else {
          showSuborders(button, form);
        }
      } else {
        hideSuborders(button, form);
      }
      button.prop('disabled', false);
    });

    $('.vendor-payment .pay-all-now').click(function(e) {
      var form;
      e.preventDefault();
      form = $(this).parents('form');
      form.find('.order-details input[type=checkbox]').prop('checked', true);
      form.find('.pay-all-now').addClass('is-invisible');
      form.find('.payment-details').removeClass('is-hidden');
    });

    $('.vendor-payment').on('click', '.pay-selected-now', function(e) {
      var element;
      e.preventDefault();
      element = $(this);
      element.addClass('is-hidden');
      element.parents('form').find('.payment-details').removeClass('is-hidden');
    });

    $('.vendor-payment-cancel > .cancel').click(function(e) {
      var element, form;
      e.preventDefault();
      element = $(this);
      form = element.parents('form');
      form.find('.payment-details').addClass('is-hidden');
      if (form.find('.order-details.is-hidden').length === 0) {
        form.find('.pay-selected-now').removeClass('is-hidden');
      } else {
        form.find('.pay-all-now').removeClass('is-invisible');
      }
    });

    $('.vendor-payment').on('change', '.seller-order-id', function(e) {
      var form, items, total;
      form = $(this).parents('form');
      items = form.find('.seller-order-id');
      total = _.reduce(items, function(total, elm) {
        elm = $(elm);
        if (elm.prop('checked')) {
          return total + parseFloat(elm.data('owed'));
        } else {
          return total;
        }
      }, 0);
      form.find('.total-owed').html(accounting.formatMoney(total));
    });

    $('.vendor-payment .payment-types input[type=radio]').change(function(e) {
      var details, option, paymentDetails;
      option = $(this);
      paymentDetails = option.parents('.payment-details');
      paymentDetails.find('input[type=text]').prop('disabled', true);
      paymentDetails.find('.cash').not('.is-hidden').addClass('is-hidden');
      paymentDetails.find('.check').not('.is-hidden').addClass('is-hidden');
      details = paymentDetails.find("." + (option.val()));
      details.find('input[type=text]').prop('disabled', false);
      details.removeClass('is-hidden');
      paymentDetails.find('.record-payment').removeClass('is-hidden');
    });

    $('.vendor-payment .review-orders').prop('disabled', false);
    $('.vendor-payment .pay-all-now').prop('disabled', false);

  });
})(jQuery);

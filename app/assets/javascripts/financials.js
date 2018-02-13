;(function($, undefined) {
  $(function() {

    function showSuborders(link, form) {
      form.find('.order-details').removeClass('is-hidden');
      form.find('.pay-all-now').addClass('is-invisible');
      link.html('Hide Orders');
    }

    function hideSuborders(link, form) {
      form.find('.order-details').addClass('is-hidden');
      form.find('.pay-all-now').removeClass('is-invisible');
      link.html('Review');
    }

    $('.vendor-payment .review-orders').click(function(e) {
      var form, link, paymentFields;
      e.preventDefault();
      link = $(this);
      form = link.parents('form');
      orderDetails = form.find('.order-details');
      link.prop('disabled', true);

      if (orderDetails.is(':hidden')) {
        if (orderDetails.find('tr').length === 0) {
          link.html('Retrieving ...');
          $.get($(this).attr('href'), function(data) {
            form.find('.order-details').html(data);
            showSuborders(link, form);
          });
        } else {
          showSuborders(link, form);
        }
      } else {
        hideSuborders(link, form);
      }
      link.prop('disabled', false);
    });

    $('.vendor-payment .pay-all-now').click(function(e) {
      var form;
      e.preventDefault();
      form = $(this).parents('form');
      form.find('.order-details input[type=checkbox]').prop('checked', true);
      form.find('.pay-all-now').addClass('is-invisible');
      form.find('.payment-details').removeClass('is-hidden');
    });

    $('.vendor-payment .pay-selected-now').click(function(e) {
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

  });
})(jQuery);

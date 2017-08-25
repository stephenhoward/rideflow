function ht(selector) {
    return $(selector + '.template').clone().removeClass('template').prop('outerHTML');
}
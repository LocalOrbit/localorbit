(function() {
    window.lo = window.lo || {};

    var timeframe_picker = React.createClass({
        propTypes: {
        },

        render: function () {

            return (
                <ul class="buttonGroup">
                    <li>1D</li>
                    <li class="selected">7D</li>
                    <li>MTD</li>
                    <li>YTD</li>
                </ul>
            );
        }
    });

    window.lo.timeframe_picker = timeframe_picker;
    module.exports = timeframe_picker;

}).call(this);

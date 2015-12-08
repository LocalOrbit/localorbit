(function() {
    window.lo = window.lo || {};

    var SegmentedControl = require('react-segmented-control');

    var timeframe_picker = React.createClass({
        propTypes: {
        },

        getInitialState: function() {
            return {
                interval: "1"
            }
        },

        intervalUpdated: function(value) {
            this.setState({
                interval: value
            });
            this.props.callbackParent(value); // hey parent, I've changed!
            window.lo.DashboardActions.newIntervalQuery(value);
        },

        render: function () {
            return (
                <div className="timeframe">
                    <SegmentedControl
                        onChange={this.intervalUpdated}
                        value={this.state.interval}
                        name="interval">
                        <span value="0">1D</span>
                        <span value="1">7D</span>
                        <span value="2">MTD</span>
                        <span value="3">YTD</span>
                    </SegmentedControl>
                </div>
            );
        }
    });

    window.lo.timeframe_picker = timeframe_picker;
    module.exports = timeframe_picker;

}).call(this);

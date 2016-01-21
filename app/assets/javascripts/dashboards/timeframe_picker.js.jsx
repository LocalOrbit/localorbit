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
                        <div value="0">1D</div>
                        <div value="1">7D</div>
                        <div value="2">MTD</div>
                        <div value="3">YTD</div>
                    </SegmentedControl>
                </div>
            );
        }
    });

    window.lo.timeframe_picker = timeframe_picker;
    window.require = require;

}).call(this);

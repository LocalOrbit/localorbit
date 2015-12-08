(function() {
    window.lo = window.lo || {};

    var SegmentedControl = require('react-segmented-control');

    var buyer_supplier_picker = React.createClass({
        propTypes: {
        },

        getInitialState: function() {
            return {
                selectedEntity: "B"
            }
        },

        viewEntityUpdated: function(value) {
            this.setState({
                selectedEntity: value
            });
            this.props.callbackParent(value); // hey parent, I've changed!
            window.lo.DashboardActions.newEntityQuery(value)
        },

        render: function () {
            return (
                <div className="timeframe">
                    <SegmentedControl
                        onChange={this.viewEntityUpdated}
                        value={this.state.selectedEntity}
                        name="selectedEntity">
                        <span value="B">Buyer</span>
                        <span value="S">Supplier</span>
                    </SegmentedControl>
                </div>
            );
        }
    });

    window.lo.buyer_supplier_picker = buyer_supplier_picker;
    module.exports = buyer_supplier_picker;

}).call(this);

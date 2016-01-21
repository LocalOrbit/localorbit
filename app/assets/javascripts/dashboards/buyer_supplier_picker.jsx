(function() {
    window.lo = window.lo || {};

    var SegmentedControl = require('react-segmented-control');

    var buyer_supplier_picker = React.createClass({
        propTypes: {
        },

        getInitialState: function() {
            return {
                selectedEntity: "S"
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
                        <div value="B">Buyer</div>
                        <div value="S">Supplier</div>
                    </SegmentedControl>
                </div>
            );
        }
    });

    window.lo.buyer_supplier_picker = buyer_supplier_picker;
    window.require = require;

}).call(this);

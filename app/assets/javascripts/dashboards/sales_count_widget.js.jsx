(function() {
    window.lo = window.lo || {};

    const Plotly = require('react-plotlyjs');

    var sales_count_widget = React.createClass({
        propTypes: {
            graphLabels: React.PropTypes.array,
            totalOrderCount: React.PropTypes.number,
            totalOrderCountGraph: React.PropTypes.array,
            lineColor: React.PropTypes.string,
            fillColor: React.PropTypes.string,
            axisTitle: React.PropTypes.string
        },

        render: function () {

            var self = this;
            var labels=[], data_points=[];
            var l = this.props.graphLabels;
            var j = this.props.totalOrderCountGraph;
            var lineColor = this.props.lineColor;
            var fillColor = this.props.fillColor;
            var axisTitle = this.props.axisTitle;
            var totalOrderCount;
            var orderCountGraph;
            var tickFormat;
            var axisType;
            var dTick;

            if (l) {
                $.each(l, function (i,v) {
                    if (v)
                        labels.push(v);
                });
            }

            if (j) {
                $.each(j, function (i,v) {
                    if (v)
                        data_points.push(parseFloat(v));
                });
            }

            if (axisTitle == 'Hour of Day') {
                axisType = '-';
                dTick = 2;
            }
            else if (axisTitle == 'Month of Year') {
                axisType = '-';
                dTick = 1;
            }
            else if (axisTitle == 'Day of Month') {
                axisType = '-';
                dTick = 1;
            }
            else if (axisTitle == 'Last 7 Days') {
                if (labels.length > 1) {
                    tickFormat = '%e';
                    axisType = 'date';
                }
                else {
                    axisType = 'category';
                    labels[0] = new Date(labels[0]).getUTCDay();
                }
            }

            let data = [
                {
                    type: 'bar',
                    x: labels,
                    y: data_points,
                    marker:{
                        color: fillColor
                    },
                    fillcolor: fillColor
                }
            ];
            let layout = {
                autosize: true,
                width: 290,
                height: 300,
                margin: {
                    l: 25,
                    r: 15,
                    t: 20,
                    b: 40,
                    autoexpand: true
                },
                yaxis:{
                    autorange: true,
                    zeroline:false,
                    showgrid:false,
                    autotick: false,
                    tickfont:{
                        size:10
                    }
                },
                xaxis:{
                    autorange: true,
                    showgrid:false,
                    zeroline:false,
                    autotick: false,
                    type: axisType,
                    tickformat: tickFormat,
                    title: axisTitle,
                    dtick: dTick,
                    tickfont:{
                        size:10
                    }
                }
            };
            let config = {
                displayModeBar: false
            };

            if (this.props.totalOrderCount)
                totalOrderCount = this.props.totalOrderCount;
            else
                totalOrderCount = '0';

            if (this.props.totalOrderCount && this.props.totalOrderCount != '$0') {
                orderCountGraph = (
                    <div>
                        <Plotly className="SalesCount" data={data} layout={layout} config={config}/>
                        <div style={{borderTop: '1px solid #EEE', padding: 3, marginTop:15}}>
                            <a href="/admin/orders"><span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View Details ></span></a>
                            <span className="tooltip pull-right" data-tooltip="This is the total number of orders placed for the selected period.">&nbsp;</span>
                        </div>
                    </div>);
            }
            else
                orderCountGraph = (<div style={{height: '300px', width: '290px', lineHeight: '300px', verticalAlign: 'middle', color: '#AAA', background: '#FFF', fontSize: '24px', textAlign: 'center'}}>No Data Available</div>);

            return (
                <div className="dashboard-widget large-widget">
                    <div className="top-section">
                        <div style={{float: "left"}}>
                            <div className="font-icon icon-stack-checkmark"></div>
                        </div>
                        <div style={{float: "right", paddingRight:10}}>
                            <div className="widget-value" id="totalOrderCount">
                                {totalOrderCount}
                            </div>
                            <div className="widget-label">
                                Orders Created
                            </div>
                        </div>
                        <div className="bottom-border"></div>
                    </div>
                    {orderCountGraph}
                </div>
            );
        }
    });

    window.lo.sales_count_widget = sales_count_widget;
    window.require = require;

}).call(this);

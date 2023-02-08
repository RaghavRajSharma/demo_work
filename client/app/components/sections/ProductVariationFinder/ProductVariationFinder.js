// import React, { Component, PropTypes } from 'react';
// import { connect } from 'react-redux';
// import { bindActionCreators } from 'redux';
// import { getManufacturersByCategory } from '../../../actions/ProductVariationFinderActions';
// import ProductVariationFields from './ProductVariationFields';
// console.log('checking import:');
// console.log(getManufacturersByCategory)



// class ProductVariationFinder extends Component {
//   constructor(props) {
//     super(props);
//     this.state = {
//       selectedManufacturer: '',
//       selectedModel: '',
//       selectedSize: '',
//       productsList: [],
//       sizeList: []
//     };
//   }
//   static propTypes = {
//     categoryId: PropTypes.number.isRequired
//   }

//   componentDidMount() {
//     // this.interval = setInterval(this.fetchData, 15000);
//     // add event listeners, ajax requests, or timeouts here
//     // this.props.getManufacturersByCategory()
    
//   }

//   handleManufacturerChange(e) {
//     let manufacturer = e.target.selectedOptions[0].value;
//     this.setState({
//       selectedManufacturer: manufacturer,
//       selectedModel: '',
//       selectedSize: '',
//       productsList: this.props.products[manufacturer] || [],
//       sizeList: []
//     });
//   }

//   handleModelChange(e) {
//     let model = e.target.selectedOptions[0].value;
//     this.setState({
//       selectedModel: model,
//       selectedSize: '',
//       sizeList: this.state.productsList.find(p => p.model === model).sizes
//     })
//   }

//   handleSizeChange(e) {
//     let size = e.target.selectedOptions[0].value;
//     this.setState({
//       selectedSize: size
//     });
//   }

//   listProducts() {
    
//   }

//   loadManufacturers() {
//     return getManufacturersByCategory(this.props.categoryId);
//   }
  
//   render() {
//     const { products: { manufacturers } } = this.props;
//     console.log('state');
//     console.log(this.state);
//     return (
//       <div>
//         Testing Testing....
//         <label htmlFor="custom_fields_1">Manufacturer*</label>
//         <select 
//           className="required" 
//           name="custom_fields[1]" 
//           id="manufacturer"
//           onChange={(e) => this.handleManufacturerChange(e)}
//           value={this.state.selectedManufacturer}
//         >
//           <option value="">Select one...</option>
//           {manufacturers.map((manufacturer, index)=>
//             <option value={manufacturer}>{manufacturer}</option>
//           )}
//         </select>
//         <label htmlFor="custom_fields_2">Model*</label>
//         <select 
//           className="required" 
//           name="custom_fields[2]" 
//           id="model"
//           onChange={(e) => this.handleModelChange(e)}
//           value={this.state.selectedModel}  
//         >
//           <option value="">Select one...</option> 
//           {this.state.productsList.map((product)=>
//             <option key={product.model} value={product.model}>
//               {product.model}
//             </option>
//           )}
//         </select>
//         <label htmlFor="custom_fields_3">Size*</label>
//         <select 
//           className="required" 
//           name="custom_fields[3]" 
//           id="size"
//           onChange={(e) => this.handleSizeChange(e)}
//           value={this.state.selectedSize}  
//         >
//           <option value="">Select one...</option> 
//           {this.state.sizeList.map((size)=>
//             <option key={size} value={size}>
//               {size}
//             </option>
//           )}
//         </select>
//       </div>
//     );
//   }
// }

// const mapStateToProps = ({ productVariations }) => {
//   // Whatever is returned will show up as props
//   // inside of ProductVariationFinder 
//   return {
//     productVariations
//   };
// }

// const mapDispatchToProps = function mapDispatchToProps(dispatch, ownProps) {
//   return {
//     onLoad: () => dispatch(getManufacturersByCategory(ownProps.categoryId)) 
//   };
// };


// export default connect(mapStateToProps, mapDispatchToProps)(ProductVariationFinder);
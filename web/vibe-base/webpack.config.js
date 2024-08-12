const path = require('path');

module.exports = {
  entry: './src/index.ts',
  output: {
    filename: 'vibe-base.js',
    path: path.resolve(__dirname, 'dist'),
    globalObject: 'this',
    library: {
      name: "vibe-base",
      type: "umd"
    },
  },
  mode: 'development',
  module: {
    rules: [
      {
        test: /\.ts$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
        },
      },
    ],
  },
}

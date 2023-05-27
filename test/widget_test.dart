// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


//
// import 'package:flutter_tron_api/tron/services/service/eth_transaction.dart';
// import 'package:otp/otp.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
  // print(OTP.randomSecret());
  // final _secret = 'UDAKLAVQY3H5HMQK';
  // final _issuer = 'voss';
  // final _type = 'voss';
  // final a = OTP.generateTOTPCodeString(_secret,DateTime.now().millisecondsSinceEpoch,interval: 30, algorithm: Algorithm.SHA1,isGoogle: true);
  // print(a);

  // print('otpauth://totp/$_type?secret=$_secret&issuer=$_issuer');
}

Future test() async {
  // EthTransaction ethTransaction = EthTransaction();
  // await  ethTransaction.getEthBalance('0x20649766B964543CCb56b12AF2Ea3E64AD48dA3B');
  // await ethTransaction.getErc20Balance('0x20649766B964543CCb56b12AF2Ea3E64AD48dA3B', '0xdAC17F958D2ee523a2206206994597C13D831ec7');
  // await ethTransaction.transEth('d8fbbda5c01a564e1b89639125e9484138a65a03bc1199545c549871f9776951', '0x20649766B964543CCb56b12AF2Ea3E64AD48dA3B', '0xF2468879Fe68BB4c639c6aCf1cDE3211e753538C', 0.001);
  // await ethTransaction.gettransactionbyid('0x7218e3bfa865485fd7dbed8593c4e67dea2c826ecfcb55aa1f2c6d8562bba758');
  // await ethTransaction.gettransactionbyid('0x176245b9a837e95dae069a65566e20d52d18e8cae38955732c6555bfe026f4ab');

  // await ethTransaction.transEth('0x20649766B964543CCb56b12AF2Ea3E64AD48dA3B','d8fbbda5c01a564e1b89639125e9484138a65a03bc1199545c549871f9776951', '0xF2468879Fe68BB4c639c6aCf1cDE3211e753538C', 0.00001);
  // await ethTransaction.transErc20('0xdAC17F958D2ee523a2206206994597C13D831ec7','0x20649766B964543CCb56b12AF2Ea3E64AD48dA3B','d8fbbda5c01a564e1b89639125e9484138a65a03bc1199545c549871f9776951',  '0xF2468879Fe68BB4c639c6aCf1cDE3211e753538C', 1.3);
}

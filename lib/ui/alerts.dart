import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models.dart';
import '../workspace_controller.dart';
import 'components.dart';
import 'markets.dart';
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override Widget build(BuildContext context) {final c=Get.find<WorkspaceController>();return Scaffold(appBar:AppBar(title:const Text('Price alerts')),
    body:Obx(()=>PageBody(children:[
      TitleBlock('Stay aware','Your thresholds, checked against fresh quotes.',trailing:FilledButton.icon(onPressed:() async {
        final coin=await showCoinSearch(context,pick:true);if(coin!=null&&context.mounted) showAlertEditor(context,coin);
      },icon:const Icon(Icons.add),label:const Text('Create alert'))),
      const StatusNote('Alerts are checked while SeeTru is open and when it resumes. Background monitoring, push notifications and email delivery are not enabled. Each alert triggers once.'),
      if(c.workspace.value.alerts.isEmpty) const EmptyState('No alerts yet','Choose a coin and a price threshold.'),
      if(c.workspace.value.alerts.any((a)=>a.triggeredAt!=null&&!a.read)) TextButton(onPressed:()=>action(()=>c.change((w)=>w.copy(alerts:w.alerts.map((a)=>a.copy(read:true)).toList()))),child:const Text('Mark all as read')),
      ...c.workspace.value.alerts.reversed.map((a)=>Panel(child:ListTile(contentPadding:EdgeInsets.zero,leading:Icon(a.triggeredAt==null?Icons.notifications_none:Icons.notifications_active,color:accent),
        title:Text('${a.symbol.toUpperCase()} ${a.above?'above':'below'} ${money(a.target)}'),
        subtitle:Text(a.triggeredAt==null?'Waiting for a fresh matching price':'Triggered ${stamp(a.triggeredAt)}${a.read?'':' · Unread'}'),
        trailing:IconButton(tooltip:'Delete alert',onPressed:()=>action(()=>c.change((w)=>w.copy(alerts:w.alerts.where((x)=>x.id!=a.id).toList()))),icon:const Icon(Icons.delete_outline)))))
    ])));}
}
Future<void> showAlertEditor(BuildContext context,Coin coin) async {
  final target=TextEditingController();bool above=true;
  await showDialog(context:context,builder:(context)=>StatefulBuilder(builder:(context,setState)=>AlertDialog(
    title:Text('${coin.symbol.toUpperCase()} price alert'),content:Column(mainAxisSize:MainAxisSize.min,children:[
      DropdownButton<bool>(value:above,items:const [DropdownMenuItem(value:true,child:Text('Price rises above')),DropdownMenuItem(value:false,child:Text('Price falls below'))],onChanged:(v)=>setState(()=>above=v!)),
      TextField(controller:target,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Target / USD'))]),
    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()=>action(() async {
      final n=double.tryParse(target.text);if(n==null) throw const FormatException('Enter a valid target price.');
      await Get.find<WorkspaceController>().addAlert(PriceAlert(id:DateTime.now().microsecondsSinceEpoch.toString(),coinId:coin.id,symbol:coin.symbol,target:n,above:above));
      if(context.mounted) Navigator.pop(context);
    }),child:const Text('Save alert'))])));
  target.dispose();
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/market_repository.dart';
import '../domain/models.dart';
const accent=Color(0xFF82E8B5);
String money(double? value)=>value==null?'Unavailable':NumberFormat.currency(symbol:'\$',decimalDigits:value.abs()<1?6:2).format(value);
String percent(double? value)=>value==null?'Unavailable':'${value>=0?'+':''}${value.toStringAsFixed(2)}%';
String stamp(DateTime? time)=>time==null?'No timestamp':DateFormat('MMM d, HH:mm').format(time.toLocal());
Future<void> action(Future<void> Function() task,{String? success}) async {
  try {await task();if(success!=null) Get.snackbar('SeeTru',success,snackPosition:SnackPosition.BOTTOM);}
  catch(e) {Get.snackbar('Could not complete',friendlyError(e),snackPosition:SnackPosition.BOTTOM);}
}
Future<bool> confirm(String title,String message) async =>await Get.dialog<bool>(AlertDialog(title:Text(title),content:Text(message),
  actions:[TextButton(onPressed:()=>Get.back(result:false),child:const Text('Cancel')),
    FilledButton(onPressed:()=>Get.back(result:true),child:const Text('Confirm'))]))??false;
Future<void> openSource(String link) async {
  final uri=Uri.tryParse(link);
  if(uri==null||uri.scheme!='https'||uri.host.isEmpty) throw const FormatException('A valid HTTPS source link is required.');
  if(!await launchUrl(uri,mode:LaunchMode.externalApplication)) throw const FormatException('Could not open the source.');
}
class Panel extends StatelessWidget {
  final Widget child; final EdgeInsets padding;
  const Panel({super.key,required this.child,this.padding=const EdgeInsets.all(20)});
  @override Widget build(BuildContext context)=>Container(padding:padding,decoration:BoxDecoration(
    color:Theme.of(context).colorScheme.surface,borderRadius:BorderRadius.circular(20),
    border:Border.all(color:Theme.of(context).dividerColor.withValues(alpha:.18))),child:child);
}
class PageBody extends StatelessWidget {
  final List<Widget> children; final Future<void> Function()? refresh;
  const PageBody({super.key,required this.children,this.refresh});
  @override Widget build(BuildContext context) {
    final list=ListView(padding:const EdgeInsets.all(24),physics:const AlwaysScrollableScrollPhysics(),children:[
      Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1180),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,
        children:children.expand((w)=>[w,const SizedBox(height:20)]).toList()))) ]);
    return refresh==null?list:RefreshIndicator(onRefresh:refresh!,child:list);
  }
}
class TitleBlock extends StatelessWidget {
  final String title,subtitle; final Widget? trailing;
  const TitleBlock(this.title,this.subtitle,{super.key,this.trailing});
  @override Widget build(BuildContext context)=>Wrap(alignment:WrapAlignment.spaceBetween,crossAxisAlignment:WrapCrossAlignment.center,
    spacing:20,runSpacing:12,children:[Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:Theme.of(context).textTheme.headlineMedium),const SizedBox(height:6),
      Text(subtitle,style:Theme.of(context).textTheme.bodyMedium)]),if(trailing!=null) trailing!]);
}
class StatusNote extends StatelessWidget {
  final String text; const StatusNote(this.text,{super.key});
  @override Widget build(BuildContext context)=>Panel(child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Icon(Icons.info_outline,size:20),const SizedBox(width:12),Expanded(child:Text(text))]));
}
class EmptyState extends StatelessWidget {
  final String title,body;final Widget? button;
  const EmptyState(this.title,this.body,{super.key,this.button});
  @override Widget build(BuildContext context)=>Panel(child:Padding(padding:const EdgeInsets.symmetric(vertical:40),
    child:Column(children:[const Icon(Icons.auto_awesome_outlined,size:40,color:accent),const SizedBox(height:16),
      Text(title,style:Theme.of(context).textTheme.titleLarge,textAlign:TextAlign.center),const SizedBox(height:10),
      Text(body,textAlign:TextAlign.center),if(button!=null)...[const SizedBox(height:20),button!]])));
}
class CoinAvatar extends StatelessWidget {
  final Coin coin;const CoinAvatar(this.coin,{super.key});
  @override Widget build(BuildContext context)=>CircleAvatar(backgroundColor:accent.withValues(alpha:.12),child:
    coin.image.isEmpty?Text(coin.symbol.isEmpty?'?':coin.symbol.substring(0,1).toUpperCase()):
      ClipOval(child:Image.network(coin.image,width:32,height:32,errorBuilder:(_,e,s)=>const Icon(Icons.currency_bitcoin))));
}
class CoinRow extends StatelessWidget {
  final Coin coin; final VoidCallback onTap;final Widget? trailing;
  const CoinRow(this.coin,{super.key,required this.onTap,this.trailing});
  @override Widget build(BuildContext context)=>ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
    leading:CoinAvatar(coin),title:Text(coin.name),subtitle:Text(coin.symbol.toUpperCase()),onTap:onTap,
    trailing:Row(mainAxisSize:MainAxisSize.min,children:[Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,
      children:[Text(money(coin.price)),Text(percent(coin.change),style:TextStyle(color:(coin.change??0)<0?Colors.redAccent:accent))]),
      if(trailing!=null) trailing!]));
}
class SparkChart extends StatelessWidget {
  final List<double> points;final double height;
  const SparkChart(this.points,{super.key,this.height=180});
  @override Widget build(BuildContext context)=>Semantics(label:'Price trend with ${points.length} observations',child:
    SizedBox(height:height,width:double.infinity,child:CustomPaint(painter:_LinePainter(points))));
}
class _LinePainter extends CustomPainter {
  final List<double> points;_LinePainter(this.points);
  @override void paint(Canvas canvas,Size size) {
    if(points.length<2) return;
    final low=points.reduce(math.min),high=points.reduce(math.max),span=high-low;
    final line=Path();
    for(var i=0;i<points.length;i++) {
      final x=i/(points.length-1)*size.width,y=size.height-12-(span==0?.5:(points[i]-low)/span)*(size.height-24);
      if(i==0) {line.moveTo(x,y);} else {line.lineTo(x,y);}
    }
    final area=Path.from(line)..lineTo(size.width,size.height)..lineTo(0,size.height)..close();
    canvas.drawPath(area,Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,
      colors:[Color(0x3382E8B5),Color(0x0082E8B5)]).createShader(Offset.zero&size));
    canvas.drawPath(line,Paint()..color=accent..strokeWidth=2.5..style=PaintingStyle.stroke);
  }
  @override bool shouldRepaint(_LinePainter old)=>old.points!=points;
}

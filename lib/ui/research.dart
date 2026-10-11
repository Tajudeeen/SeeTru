import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models.dart';
import '../workspace_controller.dart';
import 'components.dart';
class ResearchPage extends StatefulWidget {
  const ResearchPage({super.key});@override State<ResearchPage> createState()=>_ResearchState();
}
class _ResearchState extends State<ResearchPage> {
  String filter='All',query='';
  @override Widget build(BuildContext context) {final c=Get.find<WorkspaceController>();return Obx(() {
    final w=c.workspace.value;
    final list=(filter=='Saved'?w.saved:c.research).where((r)=>(filter=='All'||filter=='Saved'||r.category==filter)&&
      '${r.title} ${r.body} ${r.source}'.toLowerCase().contains(query.toLowerCase())).toList();
    return PageBody(refresh:c.loadResearch,children:[TitleBlock('Research with context','Funding, on-chain activity and original social sources.',
      trailing:OutlinedButton.icon(onPressed:()=>_note(context),icon:const Icon(Icons.edit_note),label:const Text('Add research note'))),
      if(c.researchLoading.value) const LinearProgressIndicator(),if(c.researchError.value.isNotEmpty) StatusNote(c.researchError.value),
      ...c.providers.entries.where((e)=>e.value!='available').map((e)=>StatusNote('${e.key}: ${e.value=='not_configured'?'not connected. Configure the server integration to load this source.':'temporarily unavailable. Other connected sources remain available.'}')),
      Wrap(spacing:8,runSpacing:8,children:['All','Funding','On-chain','Social','Saved'].map((s)=>ChoiceChip(label:Text(s),selected:filter==s,onSelected:(_)=>setState(()=>filter=s))).toList()),
      TextField(decoration:const InputDecoration(hintText:'Search research',prefixIcon:Icon(Icons.search)),onChanged:(v)=>setState(()=>query=v)),
      if(list.isEmpty&&!c.researchLoading.value) EmptyState(filter=='Saved'?'Your research library':'No research items to show',filter=='Saved'?
        'Save a sourced item or add your own research note.':'Connect a source or add a personal note. SeeTru does not invent a feed.'),
      ...list.map((r)=>Panel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Expanded(child:Text('${r.category.toUpperCase()} / ${r.source}',style:const TextStyle(color:accent,letterSpacing:1))),
          IconButton(tooltip:'Save research',onPressed:()=>action(()=>c.saveResearch(r)),icon:Icon(w.saved.any((x)=>x.id==r.id)?Icons.bookmark:Icons.bookmark_outline))]),
        Text(r.title,style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:12),Text(r.body),const SizedBox(height:16),
        Wrap(spacing:16,crossAxisAlignment:WrapCrossAlignment.center,children:[Text(r.publishedAt==null?'Source date unavailable':stamp(r.publishedAt)),
          TextButton.icon(onPressed:()=>action(()=>openSource(r.url)),icon:const Icon(Icons.open_in_new,size:16),label:const Text('Read original'))]) ])))
    ]);
  });}
  Future<void> _note(BuildContext context) async {
    final title=TextEditingController(),body=TextEditingController(),url=TextEditingController();
    await showDialog(context:context,builder:(context)=>AlertDialog(title:const Text('Save research note'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:title,maxLength:160,decoration:const InputDecoration(labelText:'Title')),const SizedBox(height:12),
      TextField(controller:body,maxLines:4,maxLength:4000,decoration:const InputDecoration(labelText:'Your note')),const SizedBox(height:12),
      TextField(controller:url,decoration:const InputDecoration(labelText:'HTTPS source URL'))])),actions:[
      TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()=>action(() async {
        final uri=Uri.tryParse(url.text.trim());
        if(title.text.trim().isEmpty||body.text.trim().isEmpty||uri?.scheme!='https'||uri!.host.isEmpty) throw const FormatException('Enter a title, note and valid HTTPS source.');
        await Get.find<WorkspaceController>().saveResearch(ResearchItem(id:'note-${DateTime.now().microsecondsSinceEpoch}',category:'Note',title:title.text.trim(),body:body.text.trim(),
          source:'Personal note',url:uri.toString(),publishedAt:DateTime.now().toUtc()));if(context.mounted) Navigator.pop(context);
      }),child:const Text('Save note'))]));
    title.dispose();body.dispose();url.dispose();
  }
}

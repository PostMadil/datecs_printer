

import 'package:datecs_printer/src/datecs_style.dart';

import 'datecs_column.dart';
import 'enums.dart';

class DatecsGenerate{
  final DatecsPaper _paperSize;
  int _maxCharsPerLine;
  DatecsStyle _styles = DatecsStyle.defaults();
  List<String> args = new List<String>();

  DatecsGenerate(this._paperSize);

  int _getMaxCharsPerLine() {
    if (_paperSize == DatecsPaper.mm58) {
      return 32;
    } else {
      return 48;
    }
  }

  String textPrint(String text, {
    DatecsStyle style = const DatecsStyle.defaults(),
    bool useRow = false
  }){
    String buffer = "";
    buffer += "{reset}";

    if(style.align == DatecsAlign.center){
      buffer += "{center}";
    }else if(style.align == DatecsAlign.right){
      buffer += "{right}";
    }

    if(style.wide){
      buffer += "{w}";
    }

    if(style.size == DatecsSize.small){
      buffer += "{s}";
    }else if(style.size == DatecsSize.high){
      buffer += "{h}";
    }

    if(style.bold){
      buffer += "{b}";
    }else if(style.italic){
      buffer += "{i}";
    }else if(style.underline){
      buffer += "{u}";
    }

    buffer += text;

    if(useRow){
     return buffer;
    }else{
      buffer += "{br}";
      args.add(buffer);
    }

  }

  feed(int i){
    for(int idx = 0; idx < i; i++){
      args.add("{br}");
    }
  }

  image(String base64){
    args.add("img%2021"+ base64);
  }

  row(List<DatecsColumn> cols){
    final isSumValid = cols.fold(0, (int sum, col) => sum + col.width) == 12;
    if (!isSumValid) {
      throw Exception('Total columns width must be equal to 12');
    }
    String text= "";
    int max_char = _getMaxCharsPerLine();
    for (int i = 0; i < cols.length; ++i) {
      int max_char_col = ((max_char / 12) * cols[i].width).floor();

      if(cols[i].text.length > max_char_col){
          var tmp = cols[i].text.substring(0, max_char_col);
          text += textPrint(tmp, style: cols[i].styles, useRow: true);
      }else{
        if(cols[i].styles.align == DatecsAlign.left){
          int restStr = max_char_col - cols[i].text.length;
          var tmp = cols[i].text;
          for(int j = 0; j < restStr; j++){
            tmp += " ";
          }
          text += textPrint(tmp, style: cols[i].styles, useRow: true);
        }else if(cols[i].styles.align == DatecsAlign.right){
          int restStr = max_char_col - cols[i].text.length;
          var tmp = "";
          for(int j = 0; j < restStr; j++){
            tmp += " ";
          }
          tmp += cols[i].text;
          text += textPrint(tmp, style: cols[i].styles, useRow: true);
        }
      }


    }
    text += "{br}";

    args.add(text);

  }


}
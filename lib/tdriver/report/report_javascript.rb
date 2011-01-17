############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of Testability Driver. 
## 
## If you have questions regarding the use of this file, please contact 
## Nokia at testabilitydriver@nokia.com . 
## 
## This library is free software; you can redistribute it and/or 
## modify it under the terms of the GNU Lesser General Public 
## License version 2.1 as published by the Free Software Foundation 
## and appearing in the file LICENSE.LGPL included in the packaging 
## of this file. 
## 
############################################################################


module TDriverReportJavascript

  def get_expand_collapse_java_script()
    java_script='<script type="text/javascript">'<<
      '/* Only set closed if JS-enabled */'<<
      "document.getElementsByTagName('html')[0].className = 'isJS';"<<
      'function tog(dt)'<<
      '{'<<
      'var display, dd=dt;'<<
      '/* get dd */'<<
      "do{ dd = dd.nextSibling } while(dd.tagName!='DD');"<<
      'toOpen =!dd.style.display;'<<
      "dd.style.display = toOpen? 'block':'';"<<
      "dt.getElementsByTagName('span')[0].innerHTML"<<
      "= toOpen? '<input id=\"Button1\" type=\"button\" value=\"Open\" class=\"btn\" />':'<input id=\"Button1\" type=\"button\" value=\"Close\" class=\"btn\" style=\"background-color: #FFFFFF\" />' ;"<<
      '}'<<
      get_table_sorting_java_script <<
      'function init()
      {
        var Table1Sorter = new TSorter;
        Table1Sorter.init(\'statistics_table\');
      }
      window.onload = init;'<<
      '</script>'
    java_script
  end
  
  def get_table_sorting_java_script()
    java_script="
  function TSorter(){
    var table = Object;
    var trs = Array;
    var ths = Array;
    var curSortCol = Object;
    var prevSortCol = '3';
    var sortType = Object;

    function get(){}

    function getCell(index){
      return trs[index].cells[curSortCol]
    }


    this.init = function(tableName)
    {
      table = document.getElementById(tableName);
      ths = table.getElementsByTagName(\"th\");
      for(var i = 0; i < ths.length ; i++)
      {
        ths[i].onclick = function()
        {
          sort(this);
        }
      }
      return true;
    };


    function sort(oTH)
    {
      curSortCol = oTH.cellIndex;
      sortType = oTH.abbr;
      trs = table.tBodies[0].getElementsByTagName(\"tr\");


      setGet(sortType)


      for(var j=0; j<trs.length; j++)
      {
        if(trs[j].className == 'detail_row')
        {
          closeDetails(j+2);
        }
      }

      // if already sorted just reverse
      if(prevSortCol == curSortCol)
      {
        oTH.className = (oTH.className != 'ascend' ? 'ascend' : 'descend' );
        reverseTable();
      }
      // not sorted - call quicksort
      else
      {
        oTH.className = 'ascend';
        if(ths[prevSortCol].className != 'exc_cell'){ths[prevSortCol].className = '';}
        quicksort(0, trs.length);
      }
      prevSortCol = curSortCol;
    }


    function setGet(sortType)
    {
      switch(sortType)
      {
        case \"link_column\":
          get = function(index){
            return  parseFloat(getCell(index).firstChild.firstChild.nodeValue);
          };
          break;
        default:
          get = function(index){	return parseInt(getCell(index).firstChild.nodeValue);};
          break;
      };
    }


    function exchange(i, j)
    {
      if(i == j+1) {
        table.tBodies[0].insertBefore(trs[i], trs[j]);
      } else if(j == i+1) {
        table.tBodies[0].insertBefore(trs[j], trs[i]);
      } else {
        var tmpNode = table.tBodies[0].replaceChild(trs[i], trs[j]);
        if(typeof(trs[i]) == \"undefined\") {
          table.appendChild(tmpNode);
        } else {
          table.tBodies[0].insertBefore(tmpNode, trs[i]);
        }
      }
    }


    function reverseTable()
    {
      for(var i = 1; i<trs.length; i++)
      {
        table.tBodies[0].insertBefore(trs[i], trs[0]);
      }
    }

    function quicksort(lo, hi)
    {
      if(hi <= lo+1) return;

      if((hi - lo) == 2) {
        if(get(hi-1) > get(lo)) exchange(hi-1, lo);
        return;
      }

      var i = lo + 1;
      var j = hi - 1;

      if(get(lo) > get(i)) exchange(i, lo);
      if(get(j) > get(lo)) exchange(lo, j);
      if(get(lo) > get(i)) exchange(i, lo);

      var pivot = get(lo);

      while(true) {
        j--;
        while(pivot > get(j)) j--;
        i++;
        while(get(i) > pivot) i++;
        if(j <= i) break;
        exchange(i, j);
      }
      exchange(lo, j);

      if((j-lo) < (hi-j)) {
        quicksort(lo, j);
        quicksort(j+1, hi);
      } else {
        quicksort(j+1, hi);
        quicksort(lo, j);
      }
    }
  }"
    java_script
  end


end

 

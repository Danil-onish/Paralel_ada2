with Ada.Text_IO; use Ada.Text_IO;
with System;
with Ada.Numerics.Discrete_Random;

procedure main is

   function Random(left,right : integer) return Integer is
      subtype Random_Range is Integer range left .. right;
      package R is new
        Ada.Numerics.Discrete_Random (Random_Range);
      use R;
      G : Generator;
      X : Random_Range;
   begin
      Reset (G);
      X := Random (G);
      return X;
   end Random;

   dim : Integer := Random(12,50);
   thread_num : constant  integer := Random(2,5);
   arr : array(1..dim) of integer;
   partsMin:array(1..thread_num) of Integer;
   thread_done_count : Integer := 0;

procedure Init_Arr is
   begin
      for i in 1..dim loop
         arr(i) := Random(0,99);
      end loop;
      arr(Random(1,dim)):=Random(-99,-1);
      Put_Line ("Array " & Integer'Image (dim) & ":");
      for i in 1..dim loop
         Put(Integer'Image(arr(i)));
         Put(" ");
      end loop;
      New_Line;
   end Init_Arr;

   -----
   function part_min(start_index, finish_index : in integer) return integer is
      min:Integer := arr(start_index);
      minIndex:Integer :=start_index;
   begin
      for i in (start_index+1)..finish_index loop
         if arr(i)<min then
            min:=arr(i);
            minIndex:=i;
         end if;
      end loop;
      return minIndex;
   end part_min;
   -------

   protected part_manager is
      procedure Inc_threads;
      entry get_min;
   private
      tasks_count : Integer := 0;
   end part_manager;

   protected body part_manager is
      procedure Inc_threads is
      begin
         tasks_count := tasks_count + 1;
         thread_done_count := thread_done_count +1;
      end Inc_threads;

      entry get_min when tasks_count = thread_num  is
      min :integer := arr(partsMin(thread_num));
      minIndex : Integer := partsMin(thread_num);
      begin
      for i in 1..(thread_num-1) loop
         if arr(partsMin(i)) < min then
            min :=arr(partsMin(i));
            minIndex :=partsMin(i);
         end if;
      end loop;
   Put_Line ("Min element: " & Integer'Image (arr(minIndex)) & " with index: " & Integer'Image (minIndex));
   end get_min;

   end part_manager;

task type starter_thread is
      entry start(start_index, finish_index,res_index : in Integer);
   end starter_thread;

task body starter_thread is
      start_index, finish_index,res_index : Integer;
   begin
      accept start(start_index, finish_index,res_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
         starter_thread.res_index := res_index;
      end start;
      partsMin(res_index) := part_min(start_index, finish_index);

      part_manager.Inc_threads;
   end starter_thread;
 ---
   procedure Paralel_Min is
      portion : Integer := dim / thread_num;
      ostacha : Integer := dim rem thread_num;
      thread : array(1..thread_num) of starter_thread;
      minIndex : Integer := -1;
   begin
      Put_Line("ThreadNum: " & Integer'Image(thread_num));
      Put_Line("Portion: " & Integer'Image(portion));
      Put_Line("ostacha: " & Integer'Image(ostacha));
      for i in 1..(thread_num-1) loop
         thread(i).start((i-1)*portion+1,i*portion,i);
         Put_Line("Thread[" & Integer'Image(i) & "] = new Bound("& Integer'Image((i-1)*portion+1)&", "&Integer'Image(i*portion)&")");
      end loop;
      thread(thread_num).start((thread_num-1)*portion+1,thread_num*portion+ostacha,thread_num);
      Put_Line("Thread[" & Integer'Image(thread_num) & "] = new Bound("& Integer'Image((thread_num-1)*portion+1)&", "&Integer'Image(thread_num*portion+ostacha)&")");
      part_manager.get_min;
   end Paralel_Min;

begin
   Init_Arr;
   Paralel_Min;

end main;

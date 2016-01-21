/***************************************************************
                           timer.h
 ***************************************************************/

module derelict.allegro.timer;

import derelict.allegro.base : al_long;
import derelict.allegro.internal.dintern;
import derelict.allegro.internal._export;


const TIMERS_PER_SECOND   = 1193181;
int SECS_TO_TIMER(int x) { return x * TIMERS_PER_SECOND; }
int MSEC_TO_TIMER(int x) { return x * (TIMERS_PER_SECOND / 1000); }
int BPS_TO_TIMER(int x) { return TIMERS_PER_SECOND / x; }
int BPM_TO_TIMER(int x) { return (60 * TIMERS_PER_SECOND) / x; }

alias TIMER_DRIVER ДРАЙВЕР_ТАЙМЕРА;
struct TIMER_DRIVER
{
alias id ид;
alias name имя;
alias desc щпис;
alias ascii_name аски_имя;
alias init иниц;
alias exit выход;
alias install_int установи_инт;
alias remove_int удали_инт;
alias install_param_int установи_парам_инт;
alias remove_param_int удали_парам_инт;
alias rest остаток;
//alias can_simulate_retrace 

   int id;
   const char *name;
   const char *desc;
   const char *ascii_name;
   int (*init) ();
   void (*exit) ();
   int (*install_int) (void (*proc) (), al_long speed);
   void (*remove_int) (void (*proc) ());
   int (*install_param_int) (void (*proc) (void *param), void *param, al_long speed);
   void (*remove_param_int) (void (*proc) (void *param), void *param);
   int (*can_simulate_retrace) ();
   void (*simulate_retrace) (int enable);
   void (*rest) (uint tyme, void (*callback) ());
}

extern (C) {

mixin(_export!("extern TIMER_DRIVER * timer_driver;"));
// FIXME: is it ok to set length to zero?
// Should work as long as it's only used by C code.
//mixin(_export!("extern _DRIVER_INFO _timer_driver_list[0];"));

int install_timer ();
alias install_timer установи_таймер;

void remove_timer ();
alias remove_timer удали_таймер;

int install_int_ex (void (*proc) (), al_long speed);
alias install_int установи_инт_доп;

int install_int (void (*proc) (), al_long speed);
alias install_int установи_инт;

void remove_int (void (*proc) ());
alias remove_int удали_инт;

int install_param_int_ex (void (*proc) (void *param), void *param, al_long speed);
alias install_param_int установи_парам_инт_доп;

int install_param_int (void (*proc) (void *param), void *param, al_long speed);
alias install_param_int установи_парам_инт;

void remove_param_int (void (*proc) (void *param), void *param);
alias remove_param_int удали_парам_инт;

}  // extern (C)

int retrace_count() { volatile return derelict.allegro.internal.dintern.retrace_count; }


extern (C) {

void rest (uint tyme);
alias rest остаток;
void rest_callback (uint tyme, void (*callback) ());
alias rest остаток_обрвызов;

} // extern (C)

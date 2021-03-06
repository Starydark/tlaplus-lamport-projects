------------------------ MODULE AJupiterImplXJupiter ------------------------
EXTENDS AJupiterExtended, GraphStateSpace
-----------------------------------------------------------------------------
VARIABLES c2ss, s2ss

varsImpl == <<varsEx, c2ss, s2ss>>

TypeOKImpl ==
    /\ TypeOKEx
    /\ \A c \in Client: IsSS(c2ss[c]) /\ IsSS(s2ss[c])
-----------------------------------------------------------------------------
InitImpl ==
    /\ InitEx
    /\ c2ss = [c \in Client |-> EmptySS]    
    /\ s2ss = [c \in Client |-> EmptySS]    

DoOpImpl(c, op) == 
    /\ DoOpEx(c, op)
    /\ LET cop == [op |-> op, oid |-> [c |-> c, seq |-> cseq[c]], ctx |-> ds[c]] 
       IN  c2ss' = [c2ss EXCEPT ![c] = 
                        @ (+) [node |-> {ds'[c]},
                               edge |-> {[from |-> ds[c], to |-> ds'[c], cop |-> cop]}]]
    /\ UNCHANGED s2ss

DoImpl(c) == 
    /\ DoCtx(c)
    /\ DoInt(DoOpImpl, c) \* TODO: refactor to use DoEx(c)
    /\ UNCHANGED <<sbuf, srec>>

RevImpl(c) ==
    /\ RevEx(c)
    /\ LET m == Head(cincoming[c])
           cBuf == cbuf[c]
           cShiftedBuf == SubSeq(cBuf, m.ack + 1, Len(cBuf))  
           xform == xFormCopCops(m.cop, cShiftedBuf) \* [xcop, xss, lss]
       IN  c2ss' = [c2ss EXCEPT ![c] = @ (+) xform.xss]
    /\ UNCHANGED s2ss

SRevImpl ==
    /\ SRevEx
    /\ LET m == Head(sincoming)
           c == ClientOf(m.cop)
           cBuf == sbuf[c]
           cShiftedBuf == SubSeq(cBuf, m.ack + 1, Len(cBuf))  
           xform == xFormCopCops(m.cop, cShiftedBuf) \* [xcop, xss, lss]
       IN  s2ss' = [cl \in Client |->
                        IF cl = c THEN s2ss[cl] (+) xform.xss ELSE s2ss[cl] (+) xform.lss]
    /\ UNCHANGED c2ss
-----------------------------------------------------------------------------
NextImpl ==
    \/ \E c \in Client: DoImpl(c) \/ RevImpl(c)
    \/ SRevImpl
    
FairnessImpl == 
    WF_varsImpl(SRevImpl \/ \E c \in Client: RevImpl(c)) 

SpecImpl == InitImpl /\ [][NextImpl]_varsImpl \* /\ FairnessImpl
-----------------------------------------------------------------------------
XJ == INSTANCE XJupiter WITH Msg <- Cop,
            cincoming <- cincomingXJ, sincoming <- sincomingXJ

THEOREM SpecImpl => XJ!Spec
=============================================================================
\* Modification History
\* Last modified Sat Jan 12 21:10:50 CST 2019 by hengxin
\* Created Sat Dec 29 18:36:51 CST 2018 by hengxin
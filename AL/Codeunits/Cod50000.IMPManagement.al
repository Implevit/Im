codeunit 50000 "IMP Management"
{
    #region Tables

    procedure T210_OnBeforeValidateJobTaskNo(var _JobJournalLine: Record "Job Journal Line"; var _xJobJournalLine: Record "Job Journal Line"; var _IsHandled: Boolean)
    var
        lc_JobTask: Record "Job Task";
    begin
        if (_JobJournalLine."Job Task No." = '') then
            _JobJournalLine.Validate("No.", '')
        else
            if lc_JobTask.Get(_JobJournalLine."Job Task No.") then
                _JobJournalLine."IMP All Inclusive" := lc_JobTask."IMP All Inclusive";
        _IsHandled := true;
    end;

    procedure T210_OnAfterSetUpNewLine(var _JobJournalLine: Record "Job Journal Line"; _LastJobJournalLine: Record "Job Journal Line"; _JobJournalTemplate: Record "Job Journal Template"; _JobJournalBatch: Record "Job Journal Batch")
    var
        lc_NosMgmt: Codeunit NoSeriesManagement;
    begin
        _JobJournalLine."Job No." := _LastJobJournalLine."Job No.";
        _JobJournalLine."Job Task No." := _LastJobJournalLine."Job Task No.";
        //_JobJournalLine."Job Planningline Line No." := _LastJobJournalLine."Job Planningline Line No.";

        if (_JobJournalLine."Document No." = '') and (_JobJournalBatch."IMP Line Nos." <> '') then begin
            CLEAR(lc_NosMgmt);
            _JobJournalLine."Document No." := lc_NosMgmt.TryGetNextNo(_JobJournalBatch."IMP Line Nos.", _JobJournalLine."Posting Date");
        end;
    end;

    procedure T210_OnAfterValidateQuantity(var _JobJournalLine: Record "Job Journal Line"; var _xJobJournalLine: Record "Job Journal Line")
    var
        lc_Job: Record Job;
    begin
        
        _JobJournalLine."IMP Hours Not To Invoice" := 0;
        _JobJournalLine."IMP Hours Not To Invoice" := 0;

        if _JobJournalLine.Type = _JobJournalLine.Type::Resource then begin
            _JobJournalLine."IMP Time on Job" := _JobJournalLine.Quantity;
            if lc_Job.GET(_JobJournalLine."Job No.") then begin
                if lc_Job."IMP Internal Job" <> lc_Job."IMP Internal Job"::" " THEN
                    _JobJournalLine."IMP Hours not to invoice" := _JobJournalLine."IMP Time on Job"
                else
                    _JobJournalLine."IMP Hours to invoice" := _JobJournalLine."IMP Time on Job";
                _JobJournalLine.TimeJob();
            end;

        end;
    end;

    #endregion Tables
}